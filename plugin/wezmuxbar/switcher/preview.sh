#!/bin/bash
# preview.sh - Shows windows/tabs for a given workspace
WORKSPACE="$1"

if [ "$WORKSPACE" = "+ Create new workspace" ]; then
	echo ""
	echo "  Type a workspace name and press Enter"
	echo "  to create a new workspace."
	echo ""
	echo "  The new workspace will open in your"
	echo "  current working directory."
	exit 0
fi

DATA=$(wezterm cli list --format json 2>/dev/null)

if [ -z "$DATA" ]; then
	echo "  No data available"
	exit 0
fi

echo ""
echo "  Workspace: $WORKSPACE"
echo "  ─────────────────────────────"
echo ""

echo "$DATA" | jq -r --arg ws "$WORKSPACE" '
  .[] | select(.workspace == $ws) |
  "  Tab \(.tab_id) | Pane \(.pane_id) | \(.title)\n  cwd: \(.cwd)\n"
'
