#!/bin/bash
# ============================================================
# One-time setup script for MacBook Air
# Run this on the MacBook to clone/sync everything from Mac Mini
# ============================================================

set -euo pipefail

MAC_MINI_HOST="${MAC_MINI_HOST:-mac-mini.local}"  # Or IP address
MAC_MINI_USER="${MAC_MINI_USER:-maximkorseko}"
OBSIDIAN_VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Maxim-Vault"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

log "=== Maxim's MacBook Air Sync Setup ==="
log "This will sync OpenClaw workspace and Obsidian vault from Mac Mini"

# ── Step 1: Sync OpenClaw Workspace ──
log "Setting up OpenClaw workspace sync..."

if [[ -d "$HOME/.kimi_openclaw/workspace" ]]; then
    log "Backing up existing workspace..."
    mv "$HOME/.kimi_openclaw/workspace" "$HOME/.kimi_openclaw/workspace.backup.$(date +%s)"
fi

# Option A: Clone from Git (if using Git remote)
# git clone YOUR_GIT_REPO ~/.kimi_openclaw/workspace

# Option B: rsync from Mac Mini (direct)
if command -v rsync &>/dev/null; then
    log "Syncing workspace from Mac Mini via rsync..."
    rsync -avz --progress "${MAC_MINI_USER}@${MAC_MINI_HOST}:~/.kimi_openclaw/workspace/" "$HOME/.kimi_openclaw/workspace/"
fi

# ── Step 2: Setup Obsidian Vault ──
log "Setting up Obsidian vault..."
mkdir -p "$OBSIDIAN_VAULT"

# The vault will sync via iCloud automatically
# We just need to make sure it exists

# ── Step 3: Install sync daemon ──
log "Installing sync daemon..."
SCRIPT_DIR="$HOME/.kimi_openclaw/workspace/scripts"
mkdir -p "$SCRIPT_DIR"

# Copy sync script (will be provided separately)
# The daemon should be installed on both machines

# ── Step 4: Setup launchd service ──
log "Setting up launchd service for auto-sync..."

LAUNCHD_PLIST="$HOME/Library/LaunchAgents/com.maxim.sync-daemon.plist"
mkdir -p "$HOME/Library/LaunchAgents"

cat > "$LAUNCHD_PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.maxim.sync-daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>${SCRIPT_DIR}/sync-daemon.sh</string>
        <string>daemon</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${HOME}/.maxim-sync/daemon.out</string>
    <key>StandardErrorPath</key>
    <string>${HOME}/.maxim-sync/daemon.err</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin</string>
    </dict>
</dict>
</plist>
EOF

launchctl load "$LAUNCHD_PLIST" 2>/dev/null || log "launchd load failed — may need manual approval"

log "=== Setup Complete ==="
log "OpenClaw workspace: $HOME/.kimi_openclaw/workspace"
log "Obsidian vault: $OBSIDIAN_VAULT"
log "Sync daemon: $LAUNCHD_PLIST"
log ""
log "To check sync status: ${SCRIPT_DIR}/sync-daemon.sh status"
