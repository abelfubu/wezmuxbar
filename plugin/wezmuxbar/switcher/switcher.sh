#!/bin/bash
# switcher.sh - Wezterm workspace switcher with fzf
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Get all pane data from wezterm
DATA=$(wezterm cli list --format json 2>/dev/null)

if [ -z "$DATA" ]; then
	echo "Error: Could not connect to wezterm mux" >&2
	exit 1
fi

# Get current pane's CWD for new workspace creation
CURRENT_CWD=$(echo "$DATA" | jq -r '[.[] | select(.is_active)] | first | .cwd // empty' 2>/dev/null | head -1)
if [ -z "$CURRENT_CWD" ]; then
	CURRENT_CWD="$HOME"
fi

# Get unique workspaces
WORKSPACES=$(echo "$DATA" | jq -r '.[].workspace' | sort -u)

# Build fzf list with create option at top
LIST=$(printf "+ Create new workspace\n%s" "$WORKSPACES")

# Run fzf with preview
# --print-query: first line = typed query, second line = selected match
RESULT=$(echo "$LIST" | fzf \
	--print-query \
	--header="Switch workspace · type a new name to create" \
	--preview="bash '$SCRIPT_DIR/preview.sh' '{}'" \
	--preview-window=right:50%:wrap \
	--prompt="  Workspace: " \
	--pointer="▶" \
	--border=rounded \
	--margin=1 \
	--padding=1 \
	2>/dev/tty) || true

# Parse fzf output
QUERY=$(echo "$RESULT" | sed -n '1p')
MATCH=$(echo "$RESULT" | sed -n '2p')

TARGET=""
ACTION=""

if [ "$MATCH" = "+ Create new workspace" ]; then
	# User selected the create entry
	if [ -n "$QUERY" ] && [ "$QUERY" != "+ Create new workspace" ]; then
		TARGET="$QUERY"
		ACTION="create"
	else
		# No name was typed, exit silently
		exit 0
	fi
elif [ -n "$MATCH" ]; then
	# User selected an existing workspace
	TARGET="$MATCH"
	ACTION="switch"
elif [ -n "$QUERY" ]; then
	# Typed a name that doesn't match any workspace - create it
	TARGET="$QUERY"
	ACTION="create"
else
	# Nothing selected, exit
	exit 0
fi

# Encode base64 (handle macOS vs Linux)
encode_base64() {
	if [[ "$(uname)" == "Darwin" ]]; then
		echo -n "$1" | base64
	else
		echo -n "$1" | base64 -w 0
	fi
}

# Communicate back to wezterm
if [ -n "$WEZTERM_PANE" ]; then
	# Running inside wezterm - use user var for proper workspace switching
	VALUE=$(encode_base64 "${ACTION}|${TARGET}|${CURRENT_CWD}")
	printf "\033]1337;SetUserVar=%s=%s\007" "wezmuxbar_switcher" "$VALUE"
	sleep 0.2
else
	# Running outside wezterm - use CLI commands directly
	if [ "$ACTION" = "create" ]; then
		wezterm cli spawn --new-window --workspace "$TARGET" --cwd "$CURRENT_CWD"
	else
		# Find a pane in the target workspace and activate it
		PANE_ID=$(echo "$DATA" | jq -r --arg ws "$TARGET" \
			'[.[] | select(.workspace == $ws)] | first | .pane_id // empty')
		if [ -n "$PANE_ID" ]; then
			wezterm cli activate-pane --pane-id "$PANE_ID"
		fi
	fi
fi
