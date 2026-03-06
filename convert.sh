
#!/usr/bin/env bash
set -euo pipefail

# Convert GitHub HTTPS remote to SSH
# Usage:
#   ./git_https_to_ssh_remote.sh [remote]
# Default remote is "origin"

REMOTE_NAME="${1:-origin}"

# Ensure we are inside a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: Not inside a git repository."
    exit 1
fi

# Get current remote URL
CURRENT_URL="$(git remote get-url "$REMOTE_NAME" 2>/dev/null || true)"

if [ -z "$CURRENT_URL" ]; then
    echo "Remote '$REMOTE_NAME' not found."
    exit 1
fi

# Convert HTTPS → SSH
case "$CURRENT_URL" in
    https://github.com/*)
        NEW_URL="git@github.com:${CURRENT_URL#https://github.com/}"
        ;;
    http://github.com/*)
        NEW_URL="git@github.com:${CURRENT_URL#http://github.com/}"
        ;;
    git@github.com:*)
        echo "Remote '$REMOTE_NAME' already uses SSH:"
        echo "  $CURRENT_URL"
        exit 0
        ;;
    *)
        echo "Remote '$REMOTE_NAME' is not a GitHub HTTPS URL:"
        echo "  $CURRENT_URL"
        exit 1
        ;;
esac

git remote set-url "$REMOTE_NAME" "$NEW_URL"

echo "Remote updated:"
echo "  $CURRENT_URL"
echo "  ->"
echo "  $NEW_URL"