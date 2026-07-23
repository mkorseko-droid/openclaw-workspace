#!/bin/bash
# ============================================================
# Claude Code Export Helper
# Helps you export Claude Code conversations to Obsidian vault
# ============================================================

VAULT_DIR="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Maxim-Vault"

echo "=== Claude Code Export Helper ==="
echo ""
echo "Claude Code doesn't have a built-in bulk export."
echo "Here are your options:"
echo ""
echo "Option 1: Manual Copy-Paste"
echo "  1. Open Claude Code: cd <project-dir> && claude"
echo "  2. Find the conversation you want to export"
echo "  3. Use your terminal's select/copy to grab the text"
echo "  4. Paste into the appropriate Obsidian note"
echo ""
echo "Option 2: Screen Recording / Screenshot"
echo "  1. Use macOS Screenshot (Cmd+Shift+5) to capture conversations"
echo "  2. Save to the project folder in the vault"
echo ""
echo "Option 3: Claude Web (if conversations sync there)"
echo "  1. Go to claude.ai/settings"
echo "  2. Look for export options in your account"
echo "  3. Download and move to vault"
echo ""
echo "Project folders in your vault:"
ls -1 "$VAULT_DIR"/04\ Ventures/*/ 2>/dev/null | grep -E "Project Index|\.md" | sed 's|.*V/|  - |'
echo ""
echo "Health folder:"
echo "  - $VAULT_DIR/05 Health/"
echo ""
echo "Life/Portugal folder:"
echo "  - $VAULT_DIR/06 Life/Portugal Move/"
echo ""
echo "Pro tip: After exporting, run the sync:"
echo "  ~/.kimi_openclaw/workspace/scripts/sync-daemon.sh once"
