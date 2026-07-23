# Maxim's Complete Knowledge & Work System

## System Status: ✅ FOUNDATION BUILT — PHASE 2 IN PROGRESS

Built: 2026-07-23 by Remote Kimi Claw  
Fixed & Extended: 2026-07-23 by OpenClaw Control UI

---

## What's Running Now

### ✅ Automated Sync Engine (FIXED)
- **File:** `scripts/sync-daemon.sh`
- **Service:** `com.maxim.sync-daemon` (launchd)
- **Trigger:** Every 5 minutes when on home WiFi
- **What it syncs:**
  - OpenClaw workspace (`~/.kimi_openclaw/workspace`) via Git ✅
  - Obsidian vault via iCloud (native, always on) ✅
- **MacBook Air:** Gets updates via Git pull when it comes online
- **iPhone:** Obsidian Mobile reads the iCloud-synced vault

**Check status:**
```bash
~/.kimi_openclaw/workspace/scripts/sync-daemon.sh status
```

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    MAXIM'S WORK SYSTEM                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐      ┌──────────────┐      ┌──────────────┐  │
│  │   Mac mini   │◄────►│   GitHub     │◄────►│ MacBook Air  │  │
│  │  (Primary)   │ git  │   Remote     │ git  │  (Mobile)    │  │
│  │              │      │              │      │              │  │
│  │ ┌──────────┐ │      │              │      │ ┌──────────┐ │  │
│  │ │OpenClaw  │ │      │              │      │ │OpenClaw  │ │  │
│  │ │Workspace │ │      │              │      │ │Workspace │ │  │
│  │ └──────────┘ │      │              │      │ └──────────┘ │  │
│  └──────┬───────┘      └──────────────┘      └──────┬───────┘  │
│         │                                           │           │
│         └─────────────┬─────────────────────────────┘           │
│                       │                                         │
│                  iCloud Drive                                   │
│                       │                                         │
│              ┌────────▼────────┐                               │
│              │  Maxim-Vault    │                               │
│              │  (Obsidian)     │                               │
│              └────────┬────────┘                               │
│                       │                                         │
│              ┌────────▼────────┐                               │
│              │   iPhone 17     │                               │
│              │ (Obsidian Mobile│                               │
│              │  Read + Review) │                               │
│              └─────────────────┘                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1. Obsidian Vault — "Maxim-Vault"

**Location:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Maxim-Vault`

**Current Structure:**
```
Maxim-Vault/
├── Home.md                          ← Start here
├── 00 Inbox/                        ← Daily capture (template ready)
├── 01 AI Education & Content/
│   ├── AI Content Creation - Workflow.md
│   └── Research - AI Landscape 2025-2026.md  ← (pending)
├── 02 iMentiX/
│   ├── iMentiX - Project Index.md
│   └── Research - iMentiX Market & Positioning.md  ← (pending)
├── 03 TheCAIO/
│   ├── TheCAIO - Project Index.md
│   └── Research - TheCAIO Market & Competitive Landscape.md  ← (pending)
├── 04 Ventures/
│   ├── Colt Group/Colt Group - Project Index.md
│   ├── Global Brother/Global Brother - Project Index.md
│   ├── Holywater/Holywater - Project Index.md
│   └── FidChem/FidChem - Project Index.md
├── 05 Health/
│   └── Thyroid - Health Record.md
├── 06 Life/
│   └── Portugal Move/Portugal Move - Tracker.md
└── 99 Meta/
    ├── Project Dashboard.md         ← Weekly review
    └── Templates/
        └── Daily Note.md
```

**Status:**
- ✅ Vault created in iCloud Drive
- ✅ Folder structure built
- ✅ Project index templates created
- ✅ Daily Note template created
- ✅ Syncs via iCloud (instant across devices)
- ❌ Needs: Your content from Claude Code conversations
- ❌ Needs: Research reports populated

---

## 2. OpenClaw Workspace Sync

**Status:**
- ✅ Git repo initialized in workspace
- ✅ Auto-commit every 5 minutes
- ✅ Launchd service running (`com.maxim.sync-daemon`)
- ⚠️ Git remote NOT configured yet — local commits only
- ⚠️ MacBook Air needs setup script run

**Next Steps:**
```bash
# 1. Set up GitHub remote (run this)
~/.kimi_openclaw/workspace/scripts/setup-git-remote.sh

# 2. On MacBook Air, run:
~/.kimi_openclaw/workspace/scripts/setup-macbook.sh
```

---

## 3. Projects Awaiting Content Export

These need your Claude Code / ChatGPT conversation exports:

| Project | Vault Location | Source | Priority |
|---------|---------------|--------|----------|
| Colt Group | `04 Ventures/Colt Group/` | Claude Code | 🔴 High |
| Global Brother | `04 Ventures/Global Brother/` | Claude Code | 🔴 High |
| Holywater | `04 Ventures/Holywater/` | Claude Code | 🔴 High |
| FidChem | `04 Ventures/FidChem/` | Claude Code | 🟡 Medium |
| Health/Thyroid | `05 Health/` | Claude Code + ChatGPT | 🟡 Medium |
| Portugal Move | `06 Life/Portugal Move/` | Claude Code | 🟡 Medium |

**How to Export:**
1. Open Claude Code: `cd <project-dir> && claude`
2. Find the conversation you want to export
3. Select and copy the relevant analysis text
4. Paste into the appropriate Obsidian note
5. The sync daemon will auto-commit it

---

## 4. Research In Progress

4 research tracks were started — results should populate in vault:

1. **iMentiX market & competitive landscape** → `02 iMentiX/`
2. **TheCAIO market & positioning** → `03 TheCAIO/`
3. **AI landscape 2025-2026** → `01 AI Education & Content/`
4. **Content apps & publishing market** → `04 Ventures/Holywater/` + `Global Brother/`

**Status:** Pending agent completion

---

## Quick Commands

```bash
# Check sync status
~/.kimi_openclaw/workspace/scripts/sync-daemon.sh status

# Force a sync now
~/.kimi_openclaw/workspace/scripts/sync-daemon.sh once

# Set up GitHub remote for workspace
~/.kimi_openclaw/workspace/scripts/setup-git-remote.sh

# View sync logs
tail -f ~/.maxim-sync/sync.log

# Set up MacBook Air (run on MacBook)
~/.kimi_openclaw/workspace/scripts/setup-macbook.sh
```

---

## Implementation Checklist

### Phase 1: Foundation ✅ (Done)
- [x] iCloud Drive sync (built-in)
- [x] Obsidian vault created with folder structure
- [x] OpenClaw workspace git repo initialized
- [x] Sync daemon built and running
- [x] Launchd service configured
- [x] Daily Note template created
- [x] Project index pages created

### Phase 2: Connect & Populate (In Progress)
- [ ] Set up GitHub remote for workspace
- [ ] Run setup-macbook.sh on MacBook Air
- [ ] Export Claude Code conversations to vault
- [ ] Review research agent outputs
- [ ] Populate project index pages with real content
- [ ] Test full round-trip sync (Mac mini → Git → MacBook)

### Phase 3: Polish (Next)
- [ ] Create dotfiles repo for shell/config sync
- [ ] Set up Raindrop.io for bookmarks
- [ ] Configure VS Code settings sync
- [ ] Weekly review routine in Project Dashboard
- [ ] iPhone Obsidian Mobile setup

---

*Last updated: 2026-07-23*  
*Next review: When Phase 2 items complete*
