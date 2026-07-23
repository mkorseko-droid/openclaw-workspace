#!/bin/bash
# ============================================================
# Git Remote Setup Helper for Maxim's OpenClaw Workspace
# Run this to connect your workspace to a GitHub/GitLab repo
# ============================================================

set -euo pipefail

WORKSPACE_DIR="$HOME/.kimi_openclaw/workspace"
SYNC_SCRIPT="$WORKSPACE_DIR/scripts/sync-daemon.sh"

echo "=== Git Remote Setup for OpenClaw Workspace ==="
echo ""
echo "This will connect your workspace to a Git remote for cross-device sync."
echo ""

# Check if git repo exists
cd "$WORKSPACE_DIR"
if [[ ! -d .git ]]; then
    echo "Initializing git repo..."
    git init
    git branch -m main 2>/dev/null || true
    git add -A
    git commit -m "Initial workspace setup" || true
fi

# Check if remote already exists
if git remote get-url origin &>/dev/null; then
    CURRENT_REMOTE=$(git remote get-url origin)
    echo "Remote already configured: $CURRENT_REMOTE"
    read -p "Do you want to change it? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing remote."
        exit 0
    fi
fi

echo ""
echo "Enter your Git remote URL. Examples:"
echo "  GitHub HTTPS: https://github.com/YOUR_USERNAME/openclaw-workspace.git"
echo "  GitHub SSH:   git@github.com:YOUR_USERNAME/openclaw-workspace.git"
echo "  GitLab:       https://gitlab.com/YOUR_USERNAME/openclaw-workspace.git"
echo ""
read -p "Git remote URL: " REMOTE_URL

if [[ -z "$REMOTE_URL" ]]; then
    echo "No URL provided. Exiting."
    exit 1
fi

# Add/update remote
git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE_URL"

echo ""
echo "Testing connection..."
if git ls-remote origin &>/dev/null; then
    echo "✅ Connection successful!"
else
    echo "⚠️  Could not connect to remote. This is normal if the repo is empty."
fi

# Push initial commit
read -p "Push workspace to remote now? [Y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Skipped. You can push later with:"
    echo "  cd $WORKSPACE_DIR && git push -u origin main"
else
    git push -u origin main || {
        echo "Push failed. Common fixes:"
        echo "  1. Create the empty repo on GitHub/GitLab first"
        echo "  2. For SSH: run 'ssh -T git@github.com' to verify auth"
        echo "  3. For HTTPS: you may need a personal access token"
    }
fi

# Update sync-daemon.sh with the remote
echo ""
echo "Updating sync daemon configuration..."
sed -i.bak "s|GIT_REMOTE=\"${GIT_REMOTE:-}\"|GIT_REMOTE=\"$REMOTE_URL\"|" "$SYNC_SCRIPT"
rm -f "$SYNC_SCRIPT.bak"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Your workspace will now:"
echo "  - Commit changes automatically every 5 minutes"
echo "  - Push to $REMOTE_URL"
echo "  - Pull updates when your MacBook comes online"
echo ""
echo "To check status: $SYNC_SCRIPT status"
echo "To force sync:   $SYNC_SCRIPT once"
