import { realpathSync, statSync } from "node:fs";
import path from "node:path";

import { createHttpHooks } from "@earendil-works/gondolin";

export interface ToolAccess {
  name: string;
  host: string;
  secretEnvVar: string;
  readOnly?: boolean;
}

/**
 * Optional JSON configuration. Keep organization hosts and token names outside
 * this extension, for example: GONDOLIN_HTTP_TOOLS='[{"name":"tracker","host":"tracker.example.com","secretEnvVar":"TRACKER_TOKEN"}]'.
 */
export function parseHttpTools(value = process.env.GONDOLIN_HTTP_TOOLS): ToolAccess[] {
  if (!value) return [];
  let parsed: unknown;
  try {
    parsed = JSON.parse(value);
  } catch {
    throw new Error("GONDOLIN_HTTP_TOOLS must be valid JSON.");
  }
  if (!Array.isArray(parsed)) throw new Error("GONDOLIN_HTTP_TOOLS must be a JSON array.");
  return parsed.map((tool): ToolAccess => {
    if (!tool || typeof tool !== "object")
      throw new Error("Each GONDOLIN_HTTP_TOOLS item must be an object.");
    const { name, host, secretEnvVar, readOnly } = tool as Record<string, unknown>;
    if (
      typeof name !== "string" ||
      typeof host !== "string" ||
      typeof secretEnvVar !== "string" ||
      !/^[A-Z][A-Z0-9_]*$/.test(secretEnvVar) ||
      (readOnly !== undefined && typeof readOnly !== "boolean")
    ) {
      throw new Error("Each HTTP tool needs name, host, secretEnvVar, and optional readOnly.");
    }
    if (!/^[A-Za-z0-9.-]+(?::\d+)?$/.test(host))
      throw new Error("HTTP tool hosts must be host names, not URLs.");
    return { name, host, secretEnvVar, readOnly };
  });
}
export const tools = parseHttpTools();
const allowedHosts = tools.map((t) => t.host);
const secrets = Object.fromEntries(
  tools.map((t) => [t.secretEnvVar, { hosts: [t.host], value: process.env[t.secretEnvVar] }]),
);
const readOnlyHosts = new Set(tools.filter((t) => t.readOnly).map((t) => t.host));
export const { httpHooks, env: secretEnv } = createHttpHooks({
  allowedHosts,
  secrets,
  isRequestAllowed: (req) =>
    !readOnlyHosts.has(new URL(req.url).host) || req.method === "GET" || req.method === "HEAD",
});

const GIT_COMMANDS = new Set([
  "status",
  "diff",
  "log",
  "show",
  "branch",
  "fetch",
  "remote",
  "worktree",
  "rev-parse",
  "merge-base",
  "ls-tree",
  "cat-file",
  "blame",
  "add",
  "commit",
  "push",
]);
const GH_READ_COMMANDS = new Set([
  "search",
  "repo list",
  "repo view",
  "pr diff",
  "pr list",
  "pr view",
  "pr checks",
  "issue list",
  "issue view",
  "run list",
  "run view",
  "release list",
  "release view",
]);
export type CommandPrefix = string[];
const SHELL_WRAPPERS = new Set([
  "sh",
  "bash",
  "zsh",
  "fish",
  "dash",
  "env",
  "command",
  "eval",
  "xargs",
]);

/**
 * Optional JSON command-prefix allowlist for organization-specific CLIs.
 * Example: GONDOLIN_COMMAND_PREFIXES='[["tracker","issue","view"]]'.
 */
export function parseCommandPrefixes(
  value = process.env.GONDOLIN_COMMAND_PREFIXES,
): CommandPrefix[] {
  if (!value) return [];
  let parsed: unknown;
  try {
    parsed = JSON.parse(value);
  } catch {
    throw new Error("GONDOLIN_COMMAND_PREFIXES must be valid JSON.");
  }
  if (!Array.isArray(parsed)) throw new Error("GONDOLIN_COMMAND_PREFIXES must be a JSON array.");
  return parsed.map((prefix): CommandPrefix => {
    if (
      !Array.isArray(prefix) ||
      prefix.length === 0 ||
      prefix.some((part) => typeof part !== "string" || !part)
    ) {
      throw new Error("Each configured command prefix must be a non-empty string array.");
    }
    const executable = prefix[0];
    if (!/^[A-Za-z0-9][A-Za-z0-9._+-]*$/.test(executable) || SHELL_WRAPPERS.has(executable)) {
      throw new Error("Configured commands must name a direct non-shell executable.");
    }
    return [...prefix];
  });
}

export const configuredCommandPrefixes = parseCommandPrefixes();

export function parseSingleCommand(command: string): string[] | null {
  const args: string[] = [];
  let current = "";
  let quote: "'" | '"' | null = null;
  let escaped = false;
  for (const char of command.trim()) {
    if (escaped) {
      if (/[;&|<>`$()\n\r]/.test(char)) return null;
      current += char;
      escaped = false;
    } else if (char === "\\") escaped = true;
    else if (quote) {
      if (char === quote) quote = null;
      else if (/[;&|<>`$()\n\r]/.test(char)) return null;
      else current += char;
    } else if (char === "'" || char === '"') quote = char;
    else if (/[;&|<>`$()\n\r]/.test(char)) return null;
    else if (/\s/.test(char)) {
      if (current) {
        args.push(current);
        current = "";
      }
    } else current += char;
  }
  if (quote || escaped || (!current && !args.length)) return null;
  if (current) args.push(current);
  return args;
}
function isInside(root: string, candidate: string): boolean {
  const relative = path.relative(root, candidate);
  return relative === "" || (!relative.startsWith("..") && !path.isAbsolute(relative));
}
function isApprovedRepoPath(value: string, cwd: string, approvedRoots: string[]): boolean {
  const resolved = path.resolve(cwd, value);
  return approvedRoots.some((root) => isInside(path.resolve(root), resolved));
}
function referencesProtectedBranch(value: string): boolean {
  return value
    .split(":")
    .map((ref) => ref.replace(/^refs\/heads\//, ""))
    .some((ref) => ref === "main" || ref === "master");
}

function validateGitWrite(subcommand: string, rest: string[]): string | null {
  if (subcommand === "add") {
    const broadFlags = [
      "-A",
      "--all",
      "-u",
      "--update",
      "--ignore-removal",
      "--pathspec-from-file",
      ".",
      ":/",
    ];
    if (rest.some((arg) => broadFlags.includes(arg) || arg.startsWith("--pathspec-from-file=")))
      return "Git staging must name explicit files; broad staging is blocked.";
    if (!rest.some((arg) => arg !== "--" && !arg.startsWith("-")))
      return "Git staging must name at least one explicit file.";
  }
  if (
    subcommand === "commit" &&
    rest.some((arg) => ["--no-verify", "--amend", "--reset-author", "-a", "--all"].includes(arg))
  )
    return "Commit bypass, broad staging, and history-rewrite flags are blocked.";
  if (subcommand === "push") {
    const blocked = [
      "--force",
      "--force-with-lease",
      "--force-if-includes",
      "-f",
      "--delete",
      "-d",
      "--mirror",
      "--all",
      "--tags",
      "--atomic",
    ];
    if (rest.some((arg) => blocked.includes(arg) || /^(--force|--delete)=/.test(arg)))
      return "Force, delete, mirror, all-refs, tags, and atomic pushes are blocked.";
    if (rest.some((arg) => arg.startsWith(":") || referencesProtectedBranch(arg)))
      return "Deleting refs and pushing to main or master are blocked.";
  }
  return null;
}

function validateGit(args: string[], cwd: string, approvedRoots: string[]): string | null {
  let index = 1;
  while (index < args.length) {
    const option = args[index];
    if (option === "-C") {
      if (!args[index + 1] || !isApprovedRepoPath(args[index + 1], cwd, approvedRoots))
        return "git -C must name a path below a configured host repository root.";
      index += 2;
    } else if (option.startsWith("--git-dir=") || option.startsWith("--work-tree=")) {
      const value = option.slice(option.indexOf("=") + 1);
      if (!value || !isApprovedRepoPath(value, cwd, approvedRoots))
        return "Git directory options must name a path below a configured host repository root.";
      index++;
    } else break;
  }
  const subcommand = args[index];
  if (!subcommand || !GIT_COMMANDS.has(subcommand)) return "This Git subcommand is not approved.";
  const rest = args.slice(index + 1);
  if (
    rest.some(
      (arg) =>
        ["--upload-pack", "--receive-pack", "--exec", "--exec-path", "--config-env", "-c"].includes(
          arg,
        ) || /^(--upload-pack|--receive-pack|--exec|--exec-path|--config-env)=/.test(arg),
    )
  )
    return "Git options that can select host executables or configuration are blocked.";
  if (subcommand === "remote" && !["-v", "get-url", "show"].includes(rest[0] ?? ""))
    return "Only read-only git remote operations are approved.";
  if (subcommand === "worktree" && !["list", "add"].includes(rest[0] ?? ""))
    return "Only git worktree list and add are approved.";
  return validateGitWrite(subcommand, rest);
}
function validateGh(args: string[]): string | null {
  if (args.some((arg) => arg === "--admin" || arg.startsWith("--admin=")))
    return "GitHub administrative operations are blocked.";
  if (args[1] === "api") {
    const methodIndex = args.findIndex((arg) => arg === "-X" || arg === "--method");
    const inlineMethod = args.find(
      (arg) => arg.startsWith("--method=") || /^-X[A-Za-z]+$/.test(arg),
    );
    const method = inlineMethod
      ? inlineMethod.replace(/^--method=|^-X/, "").toUpperCase()
      : methodIndex < 0
        ? "GET"
        : args[methodIndex + 1]?.toUpperCase();
    if (!method || !["GET", "HEAD"].includes(method)) return "gh api permits GET or HEAD only.";
    if (args.some((arg) => ["-f", "-F", "--raw-field", "--input"].includes(arg)))
      return "gh api request bodies are not approved.";
    return null;
  }
  const key = args.slice(1, 3).join(" ");
  if (GH_READ_COMMANDS.has(key) || key === "pr create" || GH_READ_COMMANDS.has(args[1] ?? ""))
    return null;
  return "This GitHub CLI operation is not approved.";
}
export type GitPathMapping = {
  guestRoot: string;
  hostRoot: string;
};

/**
 * Parse explicit guest-to-host repository mappings. Entries use
 * `<guest path>=<host path>` and are separated by `;`. There is no default
 * path: each machine chooses the guest and host roots it wants to expose.
 */
export function parseGitPathMappings(mappingsValue?: string): GitPathMapping[] {
  const entries = (mappingsValue ?? "").split(";").filter(Boolean);

  const mappings = entries.map((entry) => {
    const separator = entry.indexOf("=");
    if (separator <= 0 || separator === entry.length - 1) {
      throw new Error("GONDOLIN_GIT_PATH_MOUNTS entries must be <guest path>=<host path>.");
    }
    const guestInput = entry.slice(0, separator).trim();
    const hostInput = entry.slice(separator + 1).trim();
    if (!path.posix.isAbsolute(guestInput) || !path.isAbsolute(hostInput)) {
      throw new Error("GONDOLIN_GIT_PATH_MOUNTS paths must be absolute.");
    }
    return { guestRoot: path.posix.normalize(guestInput), hostRoot: path.resolve(hostInput) };
  });

  const guestRoots = new Set<string>();
  for (const mapping of mappings) {
    if (guestRoots.has(mapping.guestRoot)) {
      throw new Error(`Duplicate Gondolin Git guest path mapping: ${mapping.guestRoot}`);
    }
    guestRoots.add(mapping.guestRoot);
  }
  // Prefer the most-specific guest root when mappings overlap.
  return mappings.sort((left, right) => right.guestRoot.length - left.guestRoot.length);
}

function translateGitPath(value: string, mappings: GitPathMapping[]): string {
  for (const mapping of mappings) {
    const relative = path.posix.relative(mapping.guestRoot, value);
    if (relative === "" || (!relative.startsWith("..") && !path.posix.isAbsolute(relative))) {
      return path.join(mapping.hostRoot, relative);
    }
  }
  return value;
}

/** Translate only Git's repository-location options, never arbitrary arguments. */
export function translateGitGuestPaths(args: string[], mappings: GitPathMapping[]): string[] {
  if (args[0] !== "git") return args;
  return args.map((arg, index) => {
    if (args[index - 1] === "-C") return translateGitPath(arg, mappings);
    if (arg.startsWith("--git-dir=") || arg.startsWith("--work-tree=")) {
      const equals = arg.indexOf("=");
      return `${arg.slice(0, equals + 1)}${translateGitPath(arg.slice(equals + 1), mappings)}`;
    }
    return arg;
  });
}

export function hostCommandDenial(
  args: string[],
  cwd: string,
  approvedRepoRoots: string[] = [],
): string | null {
  if (!args.length) return "Empty command.";
  if (args.some((arg) => arg === "--admin" || arg.startsWith("--admin=")))
    return "Administrative operations are blocked.";
  if (args[0] === "git") return validateGit(args, cwd, approvedRepoRoots);
  if (args[0] === "gh") return validateGh(args);
  return configuredCommandPrefixes.some(
    (prefix) => args.length >= prefix.length && prefix.every((part, index) => args[index] === part),
  )
    ? null
    : "This command is not approved.";
}
export function isBrokeredCommand(command: string): boolean {
  return (
    command === "git" ||
    command === "gh" ||
    configuredCommandPrefixes.some(([name]) => name === command)
  );
}
export function hostBrokerGuidance(): string {
  return "git status/diff/log/show/branch/fetch/remote/worktree/rev-parse/merge-base/ls-tree/cat-file/blame (limited to configured Git path mappings); gh pr diff/view/checks/list, issue/repo/run/release list/view, search, and GET gh api; plus configured direct-command prefixes";
}

export type MountRequest = { sourcePath: string; readWrite?: boolean };
export type MountValidation =
  | { ok: true; sourcePath: string; readWrite: boolean }
  | { ok: false; reason: string };
type MountPathInfo = { realPath: string; isDirectory: boolean };

function inspectMountPath(sourcePath: string): MountPathInfo {
  const realPath = realpathSync(sourcePath);
  return { realPath, isDirectory: statSync(realPath).isDirectory() };
}

export function validateMountRequest(
  request: MountRequest,
  home = process.env.HOME ?? "",
  inspect = inspectMountPath,
): MountValidation {
  if (!path.isAbsolute(request.sourcePath))
    return { ok: false, reason: "Mount paths must be absolute." };

  let sourcePath: string;
  let isDirectory: boolean;
  try {
    ({ realPath: sourcePath, isDirectory } = inspect(path.resolve(request.sourcePath)));
  } catch {
    return { ok: false, reason: "Mount paths must exist and be accessible on the host." };
  }
  if (!isDirectory) return { ok: false, reason: "Only directories can be mounted." };

  const resolvedHome = path.resolve(home);
  const sensitive = [
    ".ssh",
    ".aws",
    ".azure",
    ".config/gcloud",
    ".config/google-chrome",
    ".config/Chromium",
    ".config/BraveSoftware",
    ".mozilla",
    ".kube",
    ".gnupg",
    ".pi/agent/auth.json",
    ".npmrc",
    ".netrc",
    "Library",
    ".cache",
    ".local/share",
  ];
  if (
    sensitive.some(
      (part) =>
        sourcePath === path.join(resolvedHome, part) ||
        sourcePath.startsWith(`${path.join(resolvedHome, part)}${path.sep}`),
    )
  )
    return { ok: false, reason: "This is a sensitive location and cannot be mounted." };
  if (["/", "/etc", "/usr", "/var", "/System", resolvedHome].includes(sourcePath))
    return { ok: false, reason: "System and home-directory mounts are not allowed." };

  // Every accepted request is presented to the user by gondolin_mount. This is
  // intentionally session-scoped: mounts live only in extension memory and are
  // discarded during session_shutdown. Sensitive locations stay denylisted.
  return { ok: true, sourcePath, readWrite: request.readWrite === true };
}
