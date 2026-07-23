#!/bin/bash
# ============================================================
# Maxim's Cross-Device Sync Daemon
# Runs on Mac Mini (primary) and MacBook Air (secondary)
# Auto-syncs OpenClaw workspace + Obsidian vault when on home WiFi
# ============================================================

set -euo pipefail

# ── Configuration ──
HOME_WIFI_SSID="${HOME_WIFI_SSID:-}"          # Set this to your home WiFi name
SYNC_DIR="${SYNC_DIR:-$HOME/.maxim-sync}"
LOG_FILE="${SYNC_DIR}/sync.log"
LOCK_FILE="${SYNC_DIR}/sync.lock"
OBSIDIAN_VAULT="${OBSIDIAN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Maxim-Vault}"
OPENCLAW_WORKSPACE="${OPENCLAW_WORKSPACE:-$HOME/.kimi_openclaw/workspace}"
GIT_REMOTE="${GIT_REMOTE:-}"                   # e.g., git@github.com:username/maxim-sync.git

# Sync intervals (seconds)
WIFI_CHECK_INTERVAL=30
SYNC_INTERVAL=300      # 5 minutes when on home WiFi
OFFLINE_SYNC_INTERVAL=1800  # 30 minutes when offline

# ── Helpers ──
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

get_wifi_ssid() {
    /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | awk -F': ' '/ SSID/ {print substr($0, index($0,$2))}' || true
}

is_home_wifi() {
    if [[ -z "$HOME_WIFI_SSID" ]]; then
        return 0  # If not configured, always sync
    fi
    local current_ssid
    current_ssid=$(get_wifi_ssid)
    [[ "$current_ssid" == "$HOME_WIFI_SSID" ]]
}

acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid
        pid=$(cat "$LOCK_FILE" 2>/dev/null) || true
        if kill -0 "$pid" 2>/dev/null; then
            log "Sync already running (PID $pid). Skipping."
            return 1
        fi
    fi
    echo $$ > "$LOCK_FILE"
    return 0
}

release_lock() {
    rm -f "$LOCK_FILE"
}

# ── Git Sync Functions ──
sync_openclaw_workspace() {
    log "=== Syncing OpenClaw Workspace ==="
    cd "$OPENCLAW_WORKSPACE"
    
    # Check if git repo initialized
    if [[ ! -d .git ]]; then
        log "Initializing git repo in OpenClaw workspace..."
        git init
        git branch -m main
    fi
    
    # Configure git if not already
    git config user.email "sync@maxim.local" 2>/dev/null || true
    git config user.name "Maxim Sync" 2>/dev/null || true
    
    # Stage and commit changes
    git add -A
    if git diff --cached --quiet; then
        log "No changes in OpenClaw workspace"
    else
        git commit -m "auto-sync: $(date '+%Y-%m-%d %H:%M:%S')" || true
        log "Committed OpenClaw workspace changes"
    fi
    
    # Push if remote configured
    if [[ -n "$GIT_REMOTE" ]]; then
        if ! git remote get-url origin &>/dev/null; then
            git remote add origin "$GIT_REMOTE"
        fi
        git push origin main 2>/dev/null || log "Push failed - may need to pull first"
    fi
}

sync_obsidian_vault() {
    log "=== Syncing Obsidian Vault ==="
    
    if [[ ! -d "$OBSIDIAN_VAULT" ]]; then
        log "Obsidian vault not found at $OBSIDIAN_VAULT"
        return 0
    fi
    
    cd "$OBSIDIAN_VAULT"
    
    # Check if git repo initialized
    if [[ ! -d .git ]]; then
        log "Initializing git repo in Obsidian vault..."
        git init
        git branch -m main
        
        # Create .gitignore for Obsidian
        cat > .gitignore << 'EOF'
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/graph.json
.obsidian/plugins/*/data.json
.trash/
.DS_Store
EOF
    fi
    
    git config user.email "sync@maxim.local" 2>/dev/null || true
    git config user.name "Maxim Sync" 2>/dev/null || true
    
    git add -A
    if git diff --cached --quiet; then
        log "No changes in Obsidian vault"
    else
        git commit -m "auto-sync: $(date '+%Y-%m-%d %H:%M:%S')" || true
        log "Committed Obsidian vault changes"
    fi
    
    if [[ -n "$GIT_REMOTE" ]]; then
        if ! git remote get-url origin &>/dev/null; then
            git remote add origin "$GIT_REMOTE"
        fi
        git push origin main 2>/dev/null || log "Push failed - may need to pull first"
    fi
}

# ── Pull from remote (for MacBook when it comes online) ──
pull_updates() {
    log "=== Pulling remote updates ==="
    
    for dir in "$OPENCLAW_WORKSPACE" "$OBSIDIAN_VAULT"; do
        if [[ -d "$dir/.git" ]]; then
            cd "$dir"
            git pull origin main 2>/dev/null || log "Pull failed for $dir"
        fi
    done
}

# ── Main sync function ──
run_sync() {
    if ! acquire_lock; then
        return 0
    fi
    
    trap release_lock EXIT
    
    log "Starting sync cycle..."
    
    mkdir -p "$SYNC_DIR"
    
    # Pull first to get latest
    pull_updates
    
    # Then push local changes
    sync_openclaw_workspace
    sync_obsidian_vault
    
    log "Sync cycle complete"
}

# ── Daemon mode ──
run_daemon() {
    log "Starting Maxim Sync Daemon"
    log "Home WiFi: ${HOME_WIFI_SSID:-'(any network)' }"
    log "Sync directory: $SYNC_DIR"
    
    while true; do
        if is_home_wifi; then
            log "On home WiFi — syncing..."
            run_sync
            sleep "$SYNC_INTERVAL"
        else
            log "Not on home WiFi — checking again in ${WIFI_CHECK_INTERVAL}s"
            sleep "$WIFI_CHECK_INTERVAL"
        fi
    done
}

# ── CLI ──
case "${1:-daemon}" in
    once)
        run_sync
        ;;
    daemon)
        run_daemon
        ;;
    status)
        echo "WiFi SSID: $(get_wifi_ssid)"
        echo "Home WiFi configured: ${HOME_WIFI_SSID:-'(not set)' }"
        echo "Lock file: $LOCK_FILE"
        if [[ -f "$LOCK_FILE" ]]; then
            echo "Sync lock active (PID: $(cat "$LOCK_FILE"))"
        else
            echo "No sync lock"
        fi
        echo "Recent log entries:"
        tail -20 "$LOG_FILE" 2>/dev/null || echo "(no log yet)"
        ;;
    *)
        echo "Usage: $0 {once|daemon|status}"
        exit 1
        ;;
esac
