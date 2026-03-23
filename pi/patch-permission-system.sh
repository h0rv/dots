#!/usr/bin/env sh

set -e

NPM_ROOT=$(npm root -g)
TARGET="$NPM_ROOT/pi-permission-system/src/index.ts"

if [ ! -f "$TARGET" ]; then
	echo "pi-permission-system source not found at $TARGET"
	exit 1
fi

python3 - "$TARGET" <<'PY'
from pathlib import Path
import sys

target = Path(sys.argv[1])
source = target.read_text()
old = '''    const agentName = resolveAgentName(ctx);

    if (!agentName) {
      if (ctx.hasUI) {
        ctx.ui.notify(`Skill '${skillName}' is blocked because active agent context is unavailable.`, "warning");
      }
      writeReviewLog("permission_request.blocked", {
        source: "skill_input",
        skillName,
        agentName: null,
        resolution: "missing_agent_context",
      });
      return { action: "handled" };
    }

    const check = permissionManager.checkPermission("skill", { name: skillName }, agentName ?? undefined);
'''
new = '''    const agentName = resolveAgentName(ctx);

    const check = permissionManager.checkPermission("skill", { name: skillName }, agentName ?? undefined);
'''
if new in source:
    print('pi-permission-system already patched')
    raise SystemExit(0)
if old not in source:
    print('Expected skill block snippet not found; patch not applied', file=sys.stderr)
    raise SystemExit(1)
target.write_text(source.replace(old, new))
print('Patched pi-permission-system skill input handling')
PY
