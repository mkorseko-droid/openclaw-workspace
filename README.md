# Maxim's Complete Knowledge & Work System

## What Was Built

This is your unified knowledge infrastructure — synced across Mac Mini, MacBook Air, and iPhone.

### 1. Automated Sync Engine
- **File:** `scripts/sync-daemon.sh` — runs continuously on Mac Mini
- **Trigger:** Every 5 minutes when on home WiFi
- **What it syncs:**
  - OpenClaw workspace (`~/.kimi_openclaw/workspace`) via Git
  - Obsidian vault via iCloud (auto) + Git backup
- **MacBook Air:** Gets updates automatically when it joins your home WiFi
- **iPhone:** Obsidian Mobile reads the iCloud-synced vault

### 2. Obsidian Vault — "Maxim-Vault"
**Location:** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Maxim-Vault`

**Structure:**
```
Maxim-Vault/
├── Home.md                          ← Start here
├── 00 Inbox/                        ← Daily capture
├── 01 AI Education & Content/       ← Content creation
│   ├── AI Content Creation - Workflow.md
│   └── Research - AI Landscape 2025-2026.md  ← (in progress)
├── 02 iMentiX/                      ← AI education venture
│   ├── iMentiX - Project Index.md
│   └── Research - iMentiX Market & Positioning.md  ← (in progress)
├── 03 TheCAIO/                      ← C-level AI consulting
│   ├── TheCAIO - Project Index.md
│   └── Research - TheCAIO Market & Competitive Landscape.md  ← (in progress)
├── 04 Ventures/
│   ├── Colt Group/
│   ├── Global Brother/
│   ├── Holywater/
│   └── FidChem/
├── 05 Health/
│   └── Thyroid - Health Record.md
├── 06 Life/
│   └── Portugal Move/
└── 99 Meta/
    ├── Project Dashboard.md         ← Weekly review
    ├── Templates/
    └── Scripts/
```

### 3. Research In Progress
4 parallel research agents are currently working on:
1. iMentiX market & competitive landscape
2. TheCAIO market & positioning
3. AI landscape 2025-2026 (for content creation)
4. Content apps & publishing market (Holywater + Global Brother)

Results will auto-populate in the vault.

### 4. Projects Awaiting Your Export
These need Claude Code / ChatGPT conversation exports:

| Project | Location | Source |
|---------|----------|--------|
| Colt Group | `04 Ventures/Colt Group/` | Claude Code |
| Global Brother | `04 Ventures/Global Brother/` | Claude Code |
| Holywater | `04 Ventures/Holywater/` | Claude Code |
| FidChem | `04 Ventures/FidChem/` | Claude Code |
| Health/Thyroid | `05 Health/` | Claude Code + ChatGPT |
| Portugal Move | `06 Life/Portugal Move/` | Claude Code |

## How to Export from Claude Code

Claude Code doesn't have bulk export, so:

1. **Open Claude Code:** `cd <project-dir> && claude`
2. **Find the conversation** you want to export
3. **Select and copy** the relevant analysis text
4. **Paste into the appropriate** Obsidian note (already created with structure)
5. **The sync daemon** will push it to Git automatically

Alternative: Run `scripts/export-claude-code.sh` for helper tips.

## How to Use This System

### Daily
1. Open Obsidian on any device
2. Create a new Daily Note from template
3. Drop captures in `00 Inbox`
4. Work on projects in their folders

### Weekly
1. Open `99 Meta/Project Dashboard.md`
2. Process inbox → file to project folders
3. Export any new Claude Code conversations
4. Review research notes
5. Update project statuses

### On MacBook Air
When you open your MacBook Air at home:
- It auto-joins WiFi
- Sync daemon detects home network
- Pulls latest changes from Mac Mini
- Your vault is up to date within 5 minutes

## What's Running Automatically

On your Mac Mini (24/7):
- ✅ `com.maxim.sync-daemon` — launchd service
- ✅ Syncs every 5 minutes when on home WiFi
- ✅ Logs to `~/.maxim-sync/sync.log`

Check status anytime:
```bash
~/.kimi_openclaw/workspace/scripts/sync-daemon.sh status
```

## Next Steps for You

1. **[NOW]** Open Obsidian → Open folder as vault → select `Maxim-Vault`
2. **[NOW]** Export Claude Code conversations for the 6 pending projects
3. **[This week]** Review the research reports when agents complete
4. **[This week]** Set up Git remote (optional — for off-site backup)
5. **[Ongoing]** Use Daily Note template every day

## Commands Quick Reference

```bash
# Check sync status
~/.kimi_openclaw/workspace/scripts/sync-daemon.sh status

# Force a sync now
~/.kimi_openclaw/workspace/scripts/sync-daemon.sh once

# View sync logs
tail -f ~/.maxim-sync/sync.log

# Export helper
~/.kimi_openclaw/workspace/scripts/export-claude-code.sh

# Set up MacBook Air (run on MacBook)
~/.kimi_openclaw/workspace/scripts/setup-macbook.sh
```

---
*System built: 2026-07-23*  
*Last updated: 2026-07-23*
