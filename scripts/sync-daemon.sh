#!/bin/bash
# ============================================================
# Maxim's Cross-Device Sync Daemon
# Runs on Mac Mini (primary) and MacBook Air (secondary)
# Auto-syncs OpenClaw workspace via Git
# Obsidian vault syncs via iCloud (no git needed)
# ============================================================

set -euo pipefail

# ── Configuration ──
HOME_WIFI_SSID="${HOME_WIFI_SSID:-}"          # Set this to your home WiFi name
SYNC_DIR="${SYNC_DIR:-$HOME/.maxim-sync}"
LOG_FILE="${SYNC_DIR}/sync.log"
LOCK_FILE="${SYNC_DIR}/sync.lock"
OPENCLAW_WORKSPACE="${OPENCLAW_WORKSPACE:-$HOME/.kimi_openclaw/workspace}"
GIT_REMOTE="${GIT_REMOTE:-}"                   # e.g., git@github.com:username/maxim-workspace.git

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
    
    if [[ ! -d "$OPENCLAW_WORKSPACE" ]]; then
        log "ERROR: OpenClaw workspace not found at $OPENCLAW_WORKSPACE"
        return 1
    fi
    
    cd "$OPENCLAW_WORKSPACE"
    
    # Check if git repo initialized
    if [[ ! -d .git ]]; then
        log "Initializing git repo in OpenClaw workspace..."
        git init
        git branch -m main 2>/dev/null || true
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
        if git push origin main 2>/dev/null; then
            log "Pushed to remote"
        else
            log "Push failed - may need to pull first or check remote"
        fi
    else
        log "No GIT_REMOTE configured — changes committed locally only"
    fi
}

# ── Pull from remote (for MacBook when it comes online) ──
pull_updates() {
    if [[ -z "$GIT_REMOTE" ]]; then
        return 0
    fi
    
    log "=== Pulling remote updates ==="
    
    if [[ -d "$OPENCLAW_WORKSPACE/.git" ]]; then
        cd "$OPENCLAW_WORKSPACE"
        if git pull origin main 2>/dev/null; then
            log "Pulled latest workspace changes"
        else
            log "No remote changes to pull"
        fi
    fi
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
    
    log "Sync cycle complete"
}

# ── Daemon mode ──
run_daemon() {
    log "=== Maxim Sync Daemon Started ==="
    log "Home WiFi: ${HOME_WIFI_SSID:-'(any network)'}"
    log "Sync directory: $SYNC_DIR"
    log "Workspace: $OPENCLAW_WORKSPACE"
    log "Git remote: ${GIT_REMOTE:-'(not configured)'}"
    
    while true; do
        if is_home_wifi; then
            log "On home WiFi — syncing..."
            run_sync
            log "Next sync in ${SYNC_INTERVAL}s"
            sleep "$SYNC_INTERVAL"
        else
            local current_ssid
            current_ssid=$(get_wifi_ssid)
            log "Not on home WiFi (current: '${current_ssid:-none}') — checking again in ${WIFI_CHECK_INTERVAL}s"
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
        echo "=== Maxim Sync Daemon Status ==="
        echo "WiFi SSID: $(get_wifi_ssid)"
        echo "Home WiFi configured: ${HOME_WIFI_SSID:-'(not set)'}"
        echo "Lock file: $LOCK_FILE"
        if [[ -f "$LOCK_FILE" ]]; then
            echo "Sync lock active (PID: $(cat "$LOCK_FILE"))"
        else
            echo "No sync lock"
        fi
        echo ""
        echo "Recent log entries:"
        tail -20 "$LOG_FILE" 2>/dev/null || echo "(no log yet)"
        echo ""
        echo "Git log (workspace):"
        cd "$OPENCLAW_WORKSPACE" 2>/dev/null && git log --oneline -5 2>/dev/null || echo "(not a git repo)"
        ;;
    *)
        echo "Usage: $0 {once|daemon|status}"
        exit 1
        ;;
esac
