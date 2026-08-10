/**
 * Routes Pi's file and shell tools through a Gondolin micro-VM.
 *
 * Pi bootstrap installs the Gondolin package declared in settings.json. The
 * project opened in Pi is mounted at /workspace. Extra directories require a
 * per-session approval through gondolin_mount.
 */

import path from "node:path";
import os from "node:os";
import { spawn, spawnSync } from "node:child_process";

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import {
  type BashOperations,
  createBashTool,
  createEditTool,
  createReadTool,
  createWriteTool,
  type EditOperations,
  type ReadOperations,
  type WriteOperations,
} from "@earendil-works/pi-coding-agent";

import { ReadonlyProvider, RealFSProvider, VM } from "@earendil-works/gondolin";
import {
  hostBrokerGuidance,
  hostCommandDenial,
  isBrokeredCommand,
  parseGitPathMappings,
  parseSingleCommand,
  secretEnv,
  httpHooks,
  translateGitGuestPaths,
  validateMountRequest,
} from "./policy";
import { Type } from "typebox";

const GUEST_WORKSPACE = "/workspace";
// Skills are already advertised to the agent. Mount only that explicit directory,
// read-only, so the agent can load the skills it was given.
const HOST_AGENT_SKILLS_DIR = path.join(os.homedir(), ".agents", "skills");
const GUEST_AGENT_SKILLS_DIR = "/agent-skills";
// Explicit mappings avoid coupling the extension to a developer's host layout.
// GONDOLIN_GIT_PATH_MOUNTS uses guest=host pairs separated by `;`.
const GIT_PATH_MAPPINGS = parseGitPathMappings(process.env.GONDOLIN_GIT_PATH_MOUNTS);

type AdditionalMount = { hostPath: string; guestPath: string; readWrite: boolean };

function isAdditionalMount(value: unknown): value is AdditionalMount {
  if (!value || typeof value !== "object") return false;
  const mount = value as Record<string, unknown>;
  return (
    typeof mount.hostPath === "string" &&
    typeof mount.guestPath === "string" &&
    typeof mount.readWrite === "boolean"
  );
}

function shQuote(value: string): string {
  // POSIX shell quoting: wraps in single quotes and escapes internal quotes
  return "'" + value.replace(/'/g, "'\\''") + "'";
}

function isProtectedBranch(value: string): boolean {
  return value
    .split(":")
    .map((ref) => ref.replace(/^refs\/heads\//, ""))
    .some((ref) => ref === "main" || ref === "master");
}

function currentBranch(cwd: string): string | null {
  const result = spawnSync("git", ["-C", cwd, "branch", "--show-current"], {
    encoding: "utf8",
  });
  const branch = result.status === 0 ? result.stdout.trim() : "";
  return branch || null;
}

function hostWriteGuard(args: string[], cwd: string): string | null {
  if (args[0] !== "gh" || args[1] !== "pr" || args[2] !== "create") return null;
  const rest = args.slice(3);
  const headIndex = rest.findIndex((arg) => arg === "--head" || arg === "-H");
  const head = headIndex >= 0 ? rest[headIndex + 1] : currentBranch(cwd);
  if (!head || isProtectedBranch(head))
    return "Pull requests must use a non-protected head branch.";
  return null;
}

function runHostCommand(
  args: string[],
  cwd: string,
  onData: (data: Buffer) => void,
  signal: AbortSignal,
): Promise<{ exitCode: number | null }> {
  return new Promise((resolve) => {
    const child = spawn(args[0], args.slice(1), {
      cwd,
      env: process.env,
      signal,
      stdio: ["ignore", "pipe", "pipe"],
    });
    child.stdout.on("data", onData);
    child.stderr.on("data", onData);
    child.on("error", (error) => {
      if (!signal.aborted) onData(Buffer.from(`${error.message}\n`));
    });
    child.on("close", (exitCode) => resolve({ exitCode }));
  });
}

function toGuestPath(
  localCwd: string,
  localPath: string,
  additionalMounts: AdditionalMount[] = [],
): string {
  // Pi tools pass absolute host paths; permit the workspace and shared skills only.
  const rel = path.relative(localCwd, localPath);
  if (rel === "") return GUEST_WORKSPACE;
  if (!rel.startsWith("..") && !path.isAbsolute(rel)) {
    return path.posix.join(GUEST_WORKSPACE, rel.split(path.sep).join(path.posix.sep));
  }

  for (const mount of additionalMounts) {
    const mountRel = path.relative(mount.hostPath, localPath);
    if (mountRel === "") return mount.guestPath;
    if (!mountRel.startsWith("..") && !path.isAbsolute(mountRel)) {
      return path.posix.join(mount.guestPath, mountRel.split(path.sep).join(path.posix.sep));
    }
  }

  const skillRel = path.relative(HOST_AGENT_SKILLS_DIR, localPath);
  if (skillRel === "") return GUEST_AGENT_SKILLS_DIR;
  if (!skillRel.startsWith("..") && !path.isAbsolute(skillRel)) {
    return path.posix.join(GUEST_AGENT_SKILLS_DIR, skillRel.split(path.sep).join(path.posix.sep));
  }

  throw new Error(`path is outside the permitted mounts: ${localPath}`);
}

function createGondolinReadOps(
  vm: VM,
  localCwd: string,
  additionalMounts: AdditionalMount[] = [],
): ReadOperations {
  return {
    readFile: async (p) => {
      const guestPath = toGuestPath(localCwd, p, additionalMounts);
      const r = await vm.exec(["/bin/cat", guestPath]);
      if (!r.ok) {
        throw new Error(`cat failed (${r.exitCode}): ${r.stderr}`);
      }
      return r.stdoutBuffer;
    },
    access: async (p) => {
      const guestPath = toGuestPath(localCwd, p, additionalMounts);
      const r = await vm.exec(["/bin/sh", "-lc", `test -r ${shQuote(guestPath)}`]);
      if (!r.ok) {
        throw new Error(`not readable: ${p}`);
      }
    },
    detectImageMimeType: async (p) => {
      const guestPath = toGuestPath(localCwd, p, additionalMounts);
      try {
        // Run through the shell because `file` might live in `/usr/bin` depending on the image
        const r = await vm.exec(["/bin/sh", "-lc", `file --mime-type -b ${shQuote(guestPath)}`]);
        if (!r.ok) return null;
        const m = r.stdout.trim();
        return ["image/jpeg", "image/png", "image/gif", "image/webp"].includes(m) ? m : null;
      } catch {
        return null;
      }
    },
  };
}

function createGondolinWriteOps(
  vm: VM,
  localCwd: string,
  additionalMounts: AdditionalMount[] = [],
): WriteOperations {
  return {
    writeFile: async (p, content) => {
      const guestPath = toGuestPath(localCwd, p, additionalMounts);
      const dir = path.posix.dirname(guestPath);

      // Base64 roundtrip to avoid quoting issues
      const b64 = Buffer.from(content, "utf8").toString("base64");
      const script = [
        `set -eu`,
        `mkdir -p ${shQuote(dir)}`,
        `echo ${shQuote(b64)} | base64 -d > ${shQuote(guestPath)}`,
      ].join("\n");

      const r = await vm.exec(["/bin/sh", "-lc", script]);
      if (!r.ok) {
        throw new Error(`write failed (${r.exitCode}): ${r.stderr}`);
      }
    },
    mkdir: async (dir) => {
      const guestDir = toGuestPath(localCwd, dir, additionalMounts);
      const r = await vm.exec(["/bin/mkdir", "-p", guestDir]);
      if (!r.ok) {
        throw new Error(`mkdir failed (${r.exitCode}): ${r.stderr}`);
      }
    },
  };
}

function createGondolinEditOps(
  vm: VM,
  localCwd: string,
  additionalMounts: AdditionalMount[] = [],
): EditOperations {
  const r = createGondolinReadOps(vm, localCwd, additionalMounts);
  const w = createGondolinWriteOps(vm, localCwd, additionalMounts);
  return { readFile: r.readFile, access: r.access, writeFile: w.writeFile };
}

function sanitizeEnv(env?: NodeJS.ProcessEnv): Record<string, string> | undefined {
  if (!env) return undefined;
  const out: Record<string, string> = {};
  for (const [k, v] of Object.entries(env)) {
    if (typeof v === "string") out[k] = v;
  }
  return out;
}

function createGondolinBashOps(
  vm: VM,
  localCwd: string,
  additionalMounts: AdditionalMount[] = [],
  ctx?: ExtensionContext,
): BashOperations {
  return {
    exec: async (command, cwd, { onData, signal, timeout, env }) => {
      const ac = new AbortController();
      const onAbort = () => ac.abort();
      signal?.addEventListener("abort", onAbort, { once: true });

      let timedOut = false;
      const timer =
        timeout && timeout > 0
          ? setTimeout(() => {
              timedOut = true;
              ac.abort();
            }, timeout * 1000)
          : undefined;

      try {
        const hostArgs = parseSingleCommand(command);
        const activeGitPathMappings = [
          ...GIT_PATH_MAPPINGS,
          ...additionalMounts.map((mount) => ({
            guestRoot: mount.guestPath,
            hostRoot: mount.hostPath,
          })),
        ];
        const activeHostRepositoryRoots = activeGitPathMappings.map((mapping) => mapping.hostRoot);
        const translatedHostArgs = hostArgs
          ? translateGitGuestPaths(hostArgs, activeGitPathMappings)
          : null;
        const denial = translatedHostArgs
          ? hostCommandDenial(translatedHostArgs, localCwd, activeHostRepositoryRoots)
          : "Invalid command syntax.";
        if (translatedHostArgs && !denial) {
          const guardError = hostWriteGuard(translatedHostArgs, localCwd);
          if (guardError) {
            onData(Buffer.from(`Host command broker denied this command. ${guardError}\n`));
            return { exitCode: 126 };
          }
          return await runHostCommand(translatedHostArgs, localCwd, onData, ac.signal);
        }
        if (hostArgs && isBrokeredCommand(hostArgs[0])) {
          onData(
            Buffer.from(
              `Host command broker denied this command. Use one of: ${hostBrokerGuidance()}\n`,
            ),
          );
          return { exitCode: 126 };
        }

        const guestCwd = toGuestPath(localCwd, cwd, additionalMounts);
        // `/bin/bash -lc` for a familiar environment (pipelines, expansions, etc.)
        const proc = vm.exec(["/bin/bash", "-lc", command], {
          cwd: guestCwd,
          signal: ac.signal,
          env: { ...secretEnv, ...sanitizeEnv(env) },
          stdout: "pipe",
          stderr: "pipe",
        });

        for await (const chunk of proc.output()) {
          onData(chunk.data);
        }

        const r = await proc;
        if (
          r.exitCode !== 127 ||
          !hostArgs ||
          !ctx ||
          hostArgs[0] === "git" ||
          hostArgs[0] === "gh"
        ) {
          return { exitCode: r.exitCode };
        }
        const approved = await ctx.ui.confirm(
          "Run unavailable command on host?",
          command,
        );
        if (!approved) return { exitCode: 126 };
        return await runHostCommand(hostArgs, localCwd, onData, ac.signal);
      } catch (err) {
        if (signal?.aborted) throw new Error("aborted");
        if (timedOut) throw new Error(`timeout:${timeout}`);
        throw err;
      } finally {
        if (timer) clearTimeout(timer);
        signal?.removeEventListener("abort", onAbort);
      }
    },
  };
}

export default function (pi: ExtensionAPI) {
  const localCwd = process.cwd();

  const localRead = createReadTool(localCwd);
  const localWrite = createWriteTool(localCwd);
  const localEdit = createEditTool(localCwd);
  const localBash = createBashTool(localCwd);

  let vm: VM | null = null;
  let vmStarting: Promise<VM> | null = null;
  const additionalMounts: AdditionalMount[] = [];

  async function ensureVm(ctx?: ExtensionContext) {
    if (vm) return vm;
    if (vmStarting) return vmStarting;

    vmStarting = (async () => {
      ctx?.ui.setStatus(
        "gondolin",
        ctx.ui.theme.fg("accent", `Gondolin: starting (mount ${GUEST_WORKSPACE})`),
      );

      const created = await VM.create({
        vfs: {
          mounts: {
            [GUEST_WORKSPACE]: new RealFSProvider(localCwd),
            [GUEST_AGENT_SKILLS_DIR]: new ReadonlyProvider(
              new RealFSProvider(HOST_AGENT_SKILLS_DIR),
            ),
            ...Object.fromEntries(
              additionalMounts.map((mount) => [
                mount.guestPath,
                mount.readWrite
                  ? new RealFSProvider(mount.hostPath)
                  : new ReadonlyProvider(new RealFSProvider(mount.hostPath)),
              ]),
            ),
          },
        },
        httpHooks,
        env: { ...secretEnv },
      });

      vm = created;
      ctx?.ui.setStatus(
        "gondolin",
        ctx.ui.theme.fg("accent", `Gondolin: running (${localCwd} -> ${GUEST_WORKSPACE})`),
      );
      ctx?.ui.notify(`Gondolin VM ready. Host ${localCwd} mounted at ${GUEST_WORKSPACE}`, "info");
      return created;
    })();

    return vmStarting;
  }

  pi.on("session_start", async (_event, ctx) => {
    for (const entry of [...ctx.sessionManager.getBranch()].reverse()) {
      if (entry.type !== "message" || entry.message.role !== "toolResult") continue;
      if (entry.message.toolName !== "gondolin_mount") continue;
      const details = entry.message.details as { mounts?: unknown } | undefined;
      if (!Array.isArray(details?.mounts)) continue;
      for (const mount of details.mounts) {
        if (!isAdditionalMount(mount)) continue;
        const validation = validateMountRequest({
          sourcePath: mount.hostPath,
          readWrite: mount.readWrite,
        });
        if (!validation.ok) continue;
        additionalMounts.push({
          hostPath: validation.sourcePath,
          guestPath: path.posix.join("/workspace/mounts", path.basename(validation.sourcePath)),
          readWrite: validation.readWrite,
        });
      }
      break;
    }
    await ensureVm(ctx);
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    if (!vm) return;
    ctx.ui.setStatus("gondolin", ctx.ui.theme.fg("muted", "Gondolin: stopping"));
    try {
      await vm.close();
    } finally {
      vm = null;
      vmStarting = null;
    }
  });

  pi.registerTool({
    name: "gondolin_mount",
    label: "Request Gondolin mount",
    description:
      "Request a user-approved host directory mount. Approved mounts are read-only by default; read-write requires separate confirmation.",
    parameters: Type.Object({
      sourcePath: Type.String({ description: "Absolute host directory path" }),
      readWrite: Type.Optional(
        Type.Boolean({ description: "Request read-write access (requires separate approval)" }),
      ),
    }),
    async execute(_id, params, _signal, _onUpdate, ctx) {
      const validation = validateMountRequest(params);
      if (!validation.ok)
        return {
          content: [{ type: "text", text: `Mount denied: ${validation.reason}` }],
          details: {},
        };
      const guestPath = path.posix.join("/workspace/mounts", path.basename(validation.sourcePath));
      const existingMount = additionalMounts.find(
        (mount) => mount.guestPath === guestPath || mount.hostPath === validation.sourcePath,
      );
      if (existingMount?.readWrite || (existingMount && !validation.readWrite)) {
        return {
          content: [
            {
              type: "text",
              text: `Mount already exists: ${validation.sourcePath} -> ${existingMount.guestPath} (${existingMount.readWrite ? "read-write" : "read-only"}).`,
            },
          ],
          details: {},
        };
      }
      const mode = validation.readWrite ? "read-write" : "read-only";
      const action = existingMount ? "Upgrade" : "Mount";
      const approved = await ctx.ui.confirm(
        "Approve Gondolin mount?",
        `${action} ${validation.sourcePath} at ${guestPath} to ${mode}. This restarts the Gondolin VM.`,
      );
      if (!approved)
        return {
          content: [{ type: "text", text: "Mount request was not approved." }],
          details: {},
        };
      if (existingMount) existingMount.readWrite = true;
      else
        additionalMounts.push({
          hostPath: validation.sourcePath,
          guestPath,
          readWrite: validation.readWrite,
        });
      if (vm) await vm.close();
      vm = null;
      vmStarting = null;
      await ensureVm(ctx);
      return {
        content: [
          { type: "text", text: `Mounted ${validation.sourcePath} -> ${guestPath} (${mode}).` },
        ],
        details: { mounts: additionalMounts },
      };
    },
  });

  pi.registerTool({
    ...localRead,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createReadTool(localCwd, {
        operations: createGondolinReadOps(activeVm, localCwd, additionalMounts),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localWrite,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createWriteTool(localCwd, {
        operations: createGondolinWriteOps(activeVm, localCwd, additionalMounts),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localEdit,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createEditTool(localCwd, {
        operations: createGondolinEditOps(activeVm, localCwd, additionalMounts),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  pi.registerTool({
    ...localBash,
    async execute(id, params, signal, onUpdate, ctx) {
      const activeVm = await ensureVm(ctx);
      const tool = createBashTool(localCwd, {
        operations: createGondolinBashOps(activeVm, localCwd, additionalMounts, ctx),
      });
      return tool.execute(id, params, signal, onUpdate);
    },
  });

  // Run user `!` commands inside the VM too
  pi.on("user_bash", (_event, ctx) => {
    if (!vm) return;
    return { operations: createGondolinBashOps(vm, localCwd, additionalMounts, ctx) };
  });

  // Replace the CWD line in the system prompt so the model sees /workspace
  pi.on("before_agent_start", async (event, ctx) => {
    await ensureVm(ctx);
    const modified = event.systemPrompt.replace(
      `Current working directory: ${localCwd}`,
      `Current working directory: ${GUEST_WORKSPACE} (Gondolin VM, mounted from host: ${localCwd})`,
    );
    return {
      systemPrompt: `${modified}

Host CLI broker: Use one direct command, without pipes, redirects, substitutions, or wrappers. The approved host commands are generated from the active broker policy: ${hostBrokerGuidance()}. Commands outside that policy execute in Gondolin and do not inherit host credentials.`,
    };
  });
}
