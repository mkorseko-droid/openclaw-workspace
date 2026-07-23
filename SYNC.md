# Cross-Device & AI Tool Sync Strategy

**Prepared for:** Maxim  
**Devices:** Mac mini (desktop), MacBook Air M5 (laptop), iPhone 17 Pro (mobile)  
**Date:** 2026-07-23

---

## 1. What Needs to Sync?

| Category | Examples | Sync Priority |
|----------|----------|---------------|
| **Files & Documents** | Projects, PDFs, spreadsheets, design files | 🔴 Critical |
| **Notes & Knowledge** | Meeting notes, ideas, research, SOPs | 🔴 Critical |
| **AI Conversations** | Chat history, prompts, custom GPTs/agents | 🟡 High |
| **Browser Data** | Bookmarks, passwords, tabs, history | 🟡 High |
| **Code & Dev Projects** | Git repos, configs, dotfiles | 🟡 High |
| **Tasks & Calendar** | To-dos, reminders, events | 🟡 High |
| **Media & Downloads** | Screenshots, recordings, references | 🟢 Medium |
| **App Settings** | Preferences, themes, shortcuts | 🟢 Medium |

---

## 2. Recommended Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         UNIFIED SYNC HUB                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │
│  │   iCloud     │  │  GitHub/Git  │  │    OpenClaw Workspace    │  │
│  │ (Apple Core) │  │  (Code/Proj) │  │    (AI Context Hub)      │  │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘  │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │
│  │   Obsidian   │  │   1Password  │  │     Raindrop/Notion      │  │
│  │  (Notes/PKM) │  │  (Secrets)   │  │    (Bookmarks/Ref)       │  │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         ▼                    ▼                    ▼
    ┌─────────┐        ┌──────────┐        ┌────────────┐
    │ Mac mini│◄──────►│MacBook M5│◄──────►│ iPhone 17  │
    │(Primary)│        │ (Mobile) │        │  (Pocket)  │
    └─────────┘        └──────────┘        └────────────┘
```

---

## 3. Layer-by-Layer Implementation

### Layer 1: Apple Foundation (Zero-Friction)
| Feature | What It Syncs | Setup |
|---------|---------------|-------|
| **iCloud Drive** | Files, Desktop, Documents | System Settings → Apple ID → iCloud → Drive |
| **iCloud Keychain** | Passwords, Wi-Fi, credit cards | System Settings → Passwords → Sync |
| **Safari** | Bookmarks, tabs, history | System Settings → Apple ID → iCloud → Safari |
| **Notes** | Native notes, quick captures | Already on if iCloud enabled |
| **Photos** | Screenshots, scans, media | System Settings → Photos → iCloud |
| **AirDrop** | Instant file drops | Enable in Finder/Control Center |
| **Handoff** | Continue work across devices | System Settings → AirPlay & Handoff |
| **Universal Clipboard** | Copy on one, paste on other | Same as Handoff |

**Action:** Verify all are enabled on all 3 devices. This gives you 70% coverage with zero new tools.

---

### Layer 2: AI Conversation Sync

| AI Tool | Sync Method | Cross-Device? | Notes |
|---------|-------------|---------------|-------|
| **Kimi** | Kimi account + web app | ✅ Yes | Web history syncs; app syncs via account |
| **ChatGPT** | OpenAI account | ✅ Yes | History syncs across web + app |
| **Claude** | Anthropic account | ✅ Yes | Web + app sync via login |
| **Perplexity** | Perplexity account | ✅ Yes | Search history syncs |
| **OpenClaw** | `~/.kimi_openclaw/workspace/` | ⚠️ Manual | **This needs your attention** |

**🔧 OpenClaw Workspace Sync (Critical)**
Your OpenClaw workspace lives locally on each Mac. To sync it:

**Option A: Git-Based (Recommended for tech users)**
```bash
# On Mac mini (primary)
cd ~/.kimi_openclaw/workspace
git init
git add .
git commit -m "Initial sync"

# Create private repo on GitHub/GitLab (free private repos)
git remote add origin https://github.com/YOUR_USERNAME/openclaw-sync.git
git push -u origin main

# On MacBook Air
git clone https://github.com/YOUR_USERNAME/openclaw-sync.git ~/.kimi_openclaw/workspace

# Sync script (save as ~/bin/sync-claw)
#!/bin/bash
cd ~/.kimi_openclaw/workspace
git pull
git add -A
git commit -m "sync: $(date '+%Y-%m-%d %H:%M')" 2>/dev/null || true
git push
```

**Option B: iCloud Drive Symlink (Simpler)**
```bash
# Move workspace to iCloud
mv ~/.kimi_openclaw/workspace ~/Library/Mobile\ Documents/com~apple~CloudDocs/OpenClaw-Workspace
ln -s ~/Library/Mobile\ Documents/com~apple~CloudDocs/OpenClaw-Workspace ~/.kimi_openclaw/workspace
```

**Option C: Syncthing/Resilio (P2P, no cloud)**
- Install Syncthing on both Macs
- Sync `~/.kimi_openclaw/workspace` folder
- Works locally over LAN, no cloud needed

> ⚠️ **iPhone limitation:** You cannot run OpenClaw on iPhone. For mobile AI access, use the Kimi app, ChatGPT app, or Safari to access web versions. Your workspace sync is Mac-to-Mac only.

---

### Layer 3: Notes & Knowledge Base

| Tool | Sync | Best For | Recommendation |
|------|------|----------|----------------|
| **Obsidian** | iCloud Drive / Obsidian Sync | Deep PKM, linking, local files | ⭐ **Recommended** |
| **Notion** | Cloud-native | Collaboration, databases, web clipper | Good alternative |
| **Apple Notes** | iCloud | Quick capture, handwriting, scanning | Already have it |
| **Craft** | iCloud | Beautiful docs, Apple-native | Aesthetic choice |

**Recommended Setup: Obsidian + iCloud**
1. Install Obsidian on both Macs
2. Create vault in `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main`
3. Install plugins: Dataview, Templater, Git (for backup)
4. Use on MacBook Air → edits sync instantly to Mac mini via iCloud
5. Obsidian Mobile on iPhone for reading/review (editing possible but cramped)

**Folder Structure Suggestion:**
```
📁 Obsidian Vault/
├── 📁 00 Inbox/           # Quick capture (daily notes)
├── 📁 01 Projects/        # Active work
├── 📁 02 Areas/           # Ongoing responsibilities
├── 📁 03 Resources/       # Reference material
├── 📁 04 Archive/         # Completed/inactive
└── 📁 99 Meta/            # Templates, scripts, settings
```

---

### Layer 4: Code & Development

| Tool | Purpose | Sync Method |
|------|---------|-------------|
| **GitHub/GitLab** | Source code, repos | Git push/pull |
| **GitHub Codespaces** | Cloud dev environments | Web + VS Code |
| **dotfiles repo** | Shell configs, .zshrc, aliases | Git + stow/symlink |
| **VS Code Settings Sync** | Extensions, themes, keybindings | Built-in sync (Microsoft account) |
| **JetBrains Settings Sync** | IDE configs | JetBrains account |

**Dotfiles Sync Script:**
```bash
# ~/.dotfiles (tracked in Git)
├── .zshrc
├── .gitconfig
├── .ssh/config
├── .config/karabiner/
├── scripts/
│   ├── setup-mac.sh
│   └── sync-claw.sh
└── README.md

# Install on new machine
cd ~ && git clone git@github.com:USER/dotfiles.git .dotfiles
# Run setup script that symlinks everything
```

---

### Layer 5: Browser & Web

| Tool | What It Does | Recommendation |
|------|--------------|----------------|
| **Safari** | Native, Handoff, Keychain | Default on iPhone; use on Mac too |
| **Chrome** | Extensions, dev tools, profiles | If you need Chrome-specific extensions |
| **Arc Browser** | Spaces, profiles, AI features | Great for organized work |
| **1Password** | Password manager (cross-platform) | ⭐ **Essential** |
| **Raindrop.io** | Bookmark manager, full-text search | ⭐ **Recommended** |

**Recommended Browser Strategy:**
- **Primary:** Safari (Handoff, best iPhone integration, power efficient on M-series)
- **Secondary:** Arc or Chrome (for specific extensions, dev tools, separate profiles)
- **Bookmarks:** Raindrop.io (tags, collections, full-text search, works everywhere)
- **Passwords:** 1Password (not just Keychain — shared vaults, 2FA, travel mode)

---

### Layer 6: Tasks & Calendar

| Tool | Sync | Best For |
|------|------|----------|
| **Apple Reminders** | iCloud | Simple tasks, location-based, Siri |
| **Apple Calendar** | iCloud/Google/Exchange | Events, scheduling |
| **Things 3** | Things Cloud | Premium task management |
| **Todoist** | Cloud | Cross-platform, collaboration |
| **Notion** | Cloud | Project planning + tasks combined |

**Recommendation:** Stick with Apple Reminders + Calendar for personal, add Todoist or Things 3 if you need more power.

---

## 4. The Complete Stack (Recommended)

```
┌─────────────────────────────────────────────────────────────┐
│                    YOUR FINAL STACK                         │
├─────────────────────────────────────────────────────────────┤
│  FILES        │ iCloud Drive + GitHub (code)                │
│  NOTES        │ Obsidian (iCloud-synced vault)              │
│  AI WORKSPACE │ OpenClaw → Git repo (Mac mini ↔ MacBook)    │
│  PASSWORDS    │ 1Password                                   │
│  BOOKMARKS    │ Raindrop.io                                 │
│  BROWSER      │ Safari (primary) + Arc (secondary)          │
│  TASKS        │ Apple Reminders + Calendar                  │
│  CODE         │ GitHub + VS Code Settings Sync              │
│  DOTFILES     │ Git repo + symlinks                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Opportunities

| Opportunity | Impact | Effort |
|-------------|--------|--------|
| **Context portability** | Pick up any thought on any device | Low |
| **AI memory persistence** | OpenClaw workspace travels with you | Medium |
| **Single source of truth** | No more "which version is latest?" | Medium |
| **Backup redundancy** | iCloud + Git = data safety | Low |
| **Workflow automation** | Shortcuts app bridges iPhone ↔ Mac | Medium |
| **Faster onboarding** | New device = run script, done | Medium |
| **Collaboration ready** | Git-based notes = easy sharing | Low |

---

## 6. Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| **iCloud storage full** | Medium | Upgrade to 200GB ($2.99/mo) or 2TB ($9.99/mo); monitor usage |
| **Git conflicts in OpenClaw workspace** | Medium | Don't edit on both Macs simultaneously; use sync script with auto-merge |
| **Sensitive data in Git** | High | Use `.gitignore` for secrets; never commit API keys; use 1Password for secrets |
| **iPhone can't run OpenClaw** | Low | Accept limitation; use Kimi/ChatGPT mobile apps for mobile AI |
| **Vendor lock-in (Apple)** | Medium | Keep Git-based backups; Obsidian vault is just Markdown files |
| **Sync latency (iCloud)** | Low | iCloud is near-instant on good WiFi; Git gives you offline + manual control |
| **Workspace bloat** | Medium | Archive old projects monthly; use `memory/` subfolder for time-based logs |
| **Lost device = lost access** | Medium | Enable Find My; 2FA on all accounts; 1Password emergency kit printed |

---

## 7. Implementation Roadmap

### Phase 1: Foundation (This Week — 2 hours)
- [ ] Verify iCloud Drive, Keychain, Safari sync on all 3 devices
- [ ] Set up 1Password (or verify it's syncing)
- [ ] Move OpenClaw workspace to Git (Option A above)
- [ ] Set up Obsidian vault in iCloud

### Phase 2: Optimization (Next 2 Weeks)
- [ ] Create dotfiles repo for shell/config sync
- [ ] Set up Raindrop.io for bookmarks
- [ ] Configure VS Code / JetBrains settings sync
- [ ] Create `~/bin/sync-claw` script and add to cron or shortcut

### Phase 3: Polish (Ongoing)
- [ ] Document your setup in `~/workspace/SYNC.md` (this file)
- [ ] Monthly: review what's synced, what's not, what changed
- [ ] Quarterly: test restoring workspace on a clean machine

---

## 8. Quick-Reference: Sync Status Dashboard

| Service | Mac mini | MacBook M5 | iPhone 17 | Status |
|---------|----------|------------|-----------|--------|
| iCloud Drive | ✅ | ✅ | ✅ | Verify |
| iCloud Keychain | ✅ | ✅ | ✅ | Verify |
| Safari Data | ✅ | ✅ | ✅ | Verify |
| OpenClaw (Git) | ✅ | ✅ | ❌ N/A | **Set up** |
| Obsidian | ✅ | ✅ | ✅ (read) | **Set up** |
| 1Password | ✅ | ✅ | ✅ | Verify |
| Raindrop | ✅ | ✅ | ✅ | **Set up** |
| GitHub/Code | ✅ | ✅ | ❌ (limited) | Verify |
| Reminders | ✅ | ✅ | ✅ | Verify |
| Calendar | ✅ | ✅ | ✅ | Verify |

---

*Last updated: 2026-07-23*  
*Next review: 2026-08-23*
