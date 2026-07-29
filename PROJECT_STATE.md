# Hyprland Control Center (HCC) — Project State

*Last updated: 2026-07-28 (v0.9.1)*
*See `docs/RELEASE.md` for deployment instructions.*

---

## 1. Executive Summary

HCC là Bash framework để cài đặt và quản lý Hyprland desktop — đã phát triển từ CLI tool đơn giản thành distro-agnostic system với package abstraction, TOML config, AUR packages, CI/CD, community registry, và TUI interface.

**Current status: v0.9.0 — published on AUR, 36/36 tests passing, feature-complete for daily use.**

| Metric | Value |
|---|---|
| Lines of code | 9,099 |
| Script files | 185 |
| Tests | 36 (26 unit + 10 CLI) |
| Git commits | 43 |
| Contributors | laosifu |
| Package managers | 9 (pacman, apt, dnf, zypper, nix, xbps, portage, apk, flatpak) + 4 AUR helpers |
| AUR packages | hcc-bin (stable), hcc-git (dev) |
| GitHub releases | v0.8.0, v0.9.0 |
| Built-in desktop profiles | 2 (mailong2401, end-4) |
| Community registry entries | 10 |
| Modules | 23 |
| Shell completions | bash, fish |

---

## 2. Architecture

```
User
  ↓
TUI (default) or CLI
  ↓
Module (23 modules)
  ↓
Planner → Action DSL → Executor
  ↓
Dispatcher
  ↓
Services (7 services)
  ↓
Operations (6 operation files)
  ↓
Shell Commands
```

### Core layers

| Layer | Path | Purpose |
|---|---|---|
| TUI | `modules/tui.sh` | Interactive menu (fzf → whiptail → dialog → select) |
| Package abstraction | `lib/package/` | 9 PMs + 4 AUR helpers — detect, install, remove, query, map |
| TOML config | `lib/config/read.sh` | Python + Bash parser, legacy var converter |
| Desktop registry | `lib/desktop_registry.sh` | Load/validate/list/search desktop packages — local + community |
| Display Manager | `lib/display_manager/detect.sh` | SDDM/GDM/LightDM/greetd abstraction |
| Planner | `lib/planners/` | Generate plan (package, flatpak, aur, git, copy) |
| Action types | `lib/action_types.sh` | INSTALL_PACKAGE, INSTALL_FLATPAK, INSTALL_AUR, CLONE, COPY, MKDIR, REMOVE, BACKUP, RESTORE |
| Executor | `lib/plan_executor.sh` | Execute with rollback + progress |
| Services | `services/` | Package, AUR, flatpak, git, filesystem, backup, hook, deployment |
| Operations | `operations/` | Atomic wrappers around `pm_*` and file commands |
| Session launcher | `lib/launchers/session-launcher.sh` | DM entry: reads session-active → exec Hyprland |

---

## 3. What HCC Can Do (for a user who installs it today)

### 🖥️ Desktop Management

| Feature | How |
|---|---|
| Install a complete Hyprland desktop | `hcc` → Desktop → Install → chon profile (hoac `hcc desktop install end-4`) |
| Install from GitHub URL | `hcc desktop install https://github.com/user/dots` |
| Auto-detect packages from any repo | Clone → phan tich files → tao package.conf tu dong |
| AI auto-generate package.conf | Neu co Gemini API key, AI phan tich repo va tao config |
| Uninstall with rollback | Xem truoc nhung gi se bi xoa, xac nhan, rollback neu loi |
| Update installed desktop | Git pull + cai dat lai |
| Export installed profile | `hcc desktop export <id>` → tao package.toml + conf + manifest |
| Config diff | Xem khac biet file config cu vs moi truoc khi cai |
| Community search | `hcc desktop search <keyword>` — tim trong 10 community profiles |

### 📦 Package Management

| Feature | Details |
|---|---|
| 9 PMs | pacman, apt, dnf, zypper, nix, xbps, portage, apk, flatpak |
| 4 AUR helpers | yay, paru, trizen, pamac |
| Batch install | Mot `sudo` call moi PM, detect already-installed, map names |
| Flatpak GUI apps | `FLATPAK_PACKAGES` trong config — cai flatpak alongside pacman/AUR |
| Dependency check | Kiem tra package dependency truoc khi cai |

### ⚙️ System Integration

| Feature | Details |
|---|---|
| Display Manager | Auto-detect SDDM/GDM/LightDM/greetd + install/remove `.desktop` entry |
| Session launcher | Mot DM entry cho tat ca profiles — doc `session-active` → exec Hyprland |
| Profile system | List, status, switch — profiles trong `~/.local/share/hcc/profiles/` |
| Backup/Restore | Snapshot config truoc install, restore tu backup |
| Doctor | System health check (OS, Hyprland, session, DM, hardware) + recommendations |
| Self-update | Kiem tra GitHub release, de xuat `yay -S hcc-bin` hoac `git pull` |
| Cleanup | Show cache sizes (pacman, yay, paru, flatpak, npm, pip) |
| Inventory | Liet ke system components |
| Inspect | Xem thong tin chi tiet cua mot desktop repo (local hoac URL) |

### 🖥️ TUI (Text User Interface)

| Feature | Details |
|---|---|
| Default interface | `hcc` (khong tham so) mo interactive menu |
| Menu tree | Desktop → Install/Uninstall/Update/Init/Export/Submit/Search; Profile, System, Backup, Theme/Plugin, AI, Self-Update, Help |
| 4 backends | fzf → whiptail → dialog → select (tu dong phat hien) |
| Vietnamese + English | Menu hien thi ca 2 ngon ngu |
| Auto-update menu | Module moi tu dong xuat hien trong menu |

### 🤖 AI Integration

| Feature | Details |
|---|---|
| Gemini 2.0 Flash | Auto-generate `package.conf` tu GitHub URL |
| AI fallback | URL install tu dong thu AI sau auto-detect that bai |
| Key management | `hcc ai setup/status/remove-key/help` |

### 🛡️ Safety

| Feature | Details |
|---|---|
| Plan preview | Xem truoc toan bo plan truoc khi install |
| Rollback | Tu dong rollback neu install that bai |
| Config diff | So sanh config cu vs moi truoc khi ghi de |
| Uninstall confirm | Liet ke tat ca files/repos/packages se bi xoa, xac nhan |
| Backup | Snapshot truoc install, restore sau |

---

## 4. Bundled Desktop Profiles

| ID | Author | Packages | AUR | Description |
|---|---|---|---|---|
| `mailong2401` | Mailong2401 | 16 | 7 | Hyprland + Quickshell cartoon-shell + Kitty + Fish |
| `end-4` | end-4 | 75 | 10 | illogical-impulse: Quickshell widgets, AI, Material Design |

Both have `package.toml` (TOML) + `package.conf` (legacy) + `payload/` + `hooks/`.

---

## 5. Community Registry (10 entries)

| ID | Author | Description |
|---|---|---|
| `prasanthrangan` | prasanthrangan | Hyprdots: Extensive Hyprland rice with themes, widgets |
| `khamer` | khamer | Krisp: Minimal Hyprland with Eww widgets |
| `solDoesTech` | solDoesTech | HyprV4: Gaming-focused with Nvidia support |
| `mylinuxforwork` | mylinuxforwork | ML4W: Beginner-friendly with app launcher |
| `JaKooLit` | JaKooLit | Feature-rich with Waybar, Rofi, multi-distro |
| `HyDE` | HyDE Project | Minimal, clean Hyprland desktop |
| `R7rainz` | R7rainz | Noctalia Shell, Ghostty, Fish |
| `lukaszkowalik2` | lukaszkowalik2 | Rose Pine themed, Waybar, Wofi, Pyprland |

- **Registry location:** `docs/community-registry/registry.txt` (within HCC repo)
- **Search:** `hcc desktop search <keyword>`
- **Submit:** Edit `registry.txt` + PR (guided by `hcc desktop submit`)

---

## 6. AUR Packages

| Package | Type | Status | Version |
|---|---|---|---|
| `hcc-bin` | Stable release | ✅ Published | v0.9.0-1 |
| `hcc-git` | Git version | ✅ Published | v0.9.0 |

### Known AUR fixes applied

1. **System path detection** — `bin/hcc` detects `/usr/bin` install → `PROJECT_ROOT=/usr/share/hcc`
2. **LOG_DIR** — `$HOME/.local/share/hcc/logs` (user-writable, works under sudo via HCC_REAL_HOME)
3. **PACMAN_PACKAGES** — Fixed unbound variable in `lib/config/read.sh`
4. **Symlink overwrite** — Removes symlinks before `cp -a` in filesystem operations

---

## 7. CI/CD

- `.github/workflows/test.yml` — Arch Linux container test + ShellCheck
- Runs on push/PR to main
- ShellCheck config: `.shellcheckrc`
- 36 tests verified on every push

---

## 8. Installation Methods

### AUR (recommended for Arch)
```bash
yay -S hcc-bin       # stable
hcc                   # opens TUI
```

### From source
```bash
git clone https://github.com/laosifu/Hyprland-Control-Center
cd Hyprland-Control-Center
bash hcc               # opens TUI
```

### One-liner
```bash
bash <(curl -sL https://raw.githubusercontent.com/laosifu/Hyprland-Control-Center/main/install.sh)
```

---

## 9. Version History

| Version | Date | Highlights |
|---|---|---|
| v0.9.0 | 2026-07-28 | TUI default, self-update, doctor recommendations, config diff, desktop export, AI fallback, Flatpak GUI apps, 10 community profiles, session sudo fix, complete README rewrite |
| v0.8.0 | 2026-07-28 | AUR publish, community registry, super command, CI, tech debt, release |
| v0.7.0 | 2026-07-25 | Flatpak, batch install, DM abstraction, desktop init/update wizard |
| v0.6.1 | 2026-07-25 | AI CLI, community search, bugs fixed in TOML parser |
| v0.6.0 | 2026-07-24 | TOML config, Python parser, Gemini API integration |
| v0.5.0 | 2026-07-23 | Profile system, registration, activation, session launcher |
| v0.4.0 | 2026-07-22 | Desktop registry, URL install, external manifest, conflict detection |
| v0.3.0 | 2026-07-22 | Plugin system, theme system, CLI framework expansion |
| v0.2.0 | 2026-07-21 | Backup/restore, uninstall, test framework |
| v0.1.0 | 2026-07-20 | Initial: CLI, planner, executor, basic desktop install |

---

## 10. Known Issues & Technical Debt

| Item | Status | Notes |
|---|---|---|
| Action Engine | ✅ Done | `action_engine_execute_plan()` |
| Deployment Service | ✅ Done | Extracted from desktop_pipeline |
| `hcc session setup-login` | ✅ Done | Tu dong `exec sudo`, gui HCC_REAL_HOME |
| `sudo hcc` HOME issue | ✅ Fixed | Phat hien SUDO_USER, dat HCC_REAL_HOME cho registry + launcher paths |
| PACMAN_PACKAGES unbound | ✅ Fixed | `${PACMAN_PACKAGES:-}` trong config reader |
| Symlink overwrite | ✅ Fixed | Xoa symlink truoc `cp -a` |
| TOML parser bugs | ✅ Fixed | Param name collision, subshell pipe, trailing dot, LIST skip |
| Session isolation | Removed | Gay login screen freeze |
| Distro support | ⚠️ Arch-only tested | 9 PMs supported but untested on non-Arch |
| English docs | ⚠️ Partial | README.en.md complete, docs/ trong English |

---

## 11. CLI Command Reference (34 commands)

```
TUI (default)             Interactive menu — khong can nho lenh

hcc doctor                System health check + recommendations
hcc inventory             System component inventory
hcc cleanup               Show cache sizes
hcc inspect <path|url>    Inspect a desktop repository
hcc self-update           Check for updates

hcc backup                Create config backup snapshot
hcc restore [id]          Restore from backup

hcc profile list          List installed profiles
hcc profile status        Show active profile
hcc profile switch <id>   Change active profile

hcc desktop list          List available desktops
hcc desktop search <kw>   Search community registry
hcc desktop install <id|url|dir>   Preview and install desktop
hcc desktop uninstall <id>         Remove desktop with rollback
hcc desktop update <id>            Update installed desktop
hcc desktop init [dir]             Create new profile (wizard)
hcc desktop submit <id>            Guide to submit to registry
hcc desktop export <id>            Export profile as package.toml

hcc get <profile>         Super command: auto HCC → install → login

hcc session setup-login   Create DM login entries (auto sudo)

hcc theme list/install/uninstall
hcc plugin list/install/uninstall

hcc ai setup/status/remove-key/help

hcc help                  Show help
hcc --version             Show version
```

---

## 12. Features Implemented (v0.8.0 → v0.9.0)

### From v0.8.0 roadmap — all completed:

| Feature | Status | Implementation |
|---|---|---|
| TUI mode | ✅ | `modules/tui.sh` — fzf/whiptail/dialog/select, menu tree, `hcc` default |
| Auto-update | ✅ | `modules/self_update.sh` — GitHub release check |
| `hcc doctor` recommendations | ✅ | `modules/doctor.sh` — phat hien thieu Hyprland/AUR helper/DM/python/login |
| Desktop uninstall confirm | ✅ | Hien thi chi tiet files/repos/packages truoc khi xoa |
| Config diff | ✅ | `lib/plan_diff.sh` — `diff` config cu vs moi |
| `hcc desktop export` | ✅ | `modules/desktop_export.sh` — xuat profile ra package.toml + conf + manifest + hooks |
| 5+ community profiles | ✅ | 10 entries trong registry |
| Complete English docs | ✅ | README.en.md hoan chinh |
| Flatpak GUI apps support | ✅ | FLATPAK_PACKAGES planner + INSTALL_FLATPAK action |
| Session launcher sudo fix | ✅ | HCC_REAL_HOME, session launcher path fix |
| AI fallback in URL install | ✅ | Tu dong thu AI sau auto-detect that bai |

### Remaining for future:

| Feature | Priority | Notes |
|---|---|---|
| Non-Arch E2E test | Low | Can VM Fedora/Ubuntu |
| Gemini E2E test | Low | Can Gemini API key + network |
| Profile dependencies graph | Low | Visual tree of packages/configs |
| Ansible/Puppet integration | Long-term | v2.0.0 |
| Web dashboard | Long-term | v2.0.0 |
| NixOS module | Long-term | v2.0.0 |
| Multiple profile stacking | Long-term | v2.0.0 |
| Docker dev environment | Long-term | v2.0.0 |

---

## 13. Market Evaluation & Development Assessment

### Development Maturity

| Aspect | Assessment |
|---|---|
| **Core functionality** | ✅ Production-ready. Install/uninstall/update desktop profiles works with rollback, backup, diff |
| **TUI** | ✅ Production-ready. 4 backends, full menu tree, auto-discovery of new modules |
| **Package abstraction** | ✅ 9 PMs + 4 AUR helpers. Batch install, name mapping, dependency check |
| **AI integration** | ⚠️ Experimental. Can API call works but quality depends on repo structure |
| **Error handling** | ✅ Rollback on failure, plan preview, confirm prompts, backup snapshots |
| **Test coverage** | ⚠️ 36 tests cover core paths but not edge cases or non-Arch distros |
| **Documentation** | ✅ Vietnamese README complete, English README complete, ARCHITECTURE.md |
| **Distribution** | ✅ AUR (hcc-bin, hcc-git), GitHub releases, one-liner installer |
| **Shell completions** | ✅ Bash + fish |
| **CI/CD** | ✅ GitHub Actions test on every push |

### Do Linux users need HCC?

**Current market context (2026):**
- Hyprland đang la mot trong nhung compositor Wayland pho bien nhat (15k+ GitHub stars cho end-4 dots, 3.4k+ cho JaKooLit)
- Nhu cau "dotfiles" va "ricing" tren Linux dang tang — nhung repo dotfiles hang nghin stars
- Hyprland community chua co mot tool chuan nao de cai dat va quan ly desktop profiles
- Existing solutions (archinstall, dotfiles manager) chi xu ly package install, khong co profile abstraction, rollback, config diff, AI support

**Target users:**
1. **Nguoi moi dung Hyprland (primary target):** Muon trai nghiem Hyprland nhung khong muon tu cau hinh tu dau. `hcc get end-4` = install xong desktop + login entry trong 5 phut
2. **Nguoi dung trung cap:** Muon thu nhieu desktop profiles khac nhau (end-4, JaKooLit, HyDE) ma khong so hong config cu
3. **Nguoi dung nang cao:** Muon dong goi desktop cua minh thanh HCC profile de share voi community, co rollback va dependency management
4. **Distro hoppers:** Can mot tool install desktop giong nhau tren nhieu distro khac nhau

**Competition analysis:**

| Tool | What it does | HCC advantage |
|---|---|---|
| archinstall | Cai Arch Linux + desktop packages | Khong co profile management, khong co rollback, khong co config deploy |
| dotbot/yadm/chezmoi | Quan ly dotfiles | Khong cai packages, khong co AUR, khong co DM entry setup |
| Ansible/Puppet | Config management | Qua nang cho desktop install, can knowledge |
| Manual setup | Tu clone repo + cai packages + config | Ton thoi gian, kho rollback, khong co plan preview |
| Hyprland install scripts (JaKooLit, end-4) | Install script rieng cho tung repo | Khong co unified interface, khong co profile switching, khong co plan/rollback |

**HCC's unique value:**
- **Mot lenh duy nhat** de cai bat ky Hyprland desktop nao (built-in, URL, community)
- **Plan + rollback + diff** — an toan khi thu desktop moi
- **Profile switching** — chuyen giua cac desktop profiles khac nhau
- **AI auto-detection** — tu dong phan tich repo URL khong co package.conf
- **Package abstraction** — cai duoc tren 9 distro khac nhau (pacman, apt, dnf, etc.)
- **TUI** — khong can nho lenh, menu tuong tac

**Market timing assessment:**
- **Hyprland adoption** dang o dinh cao (2024-2026) — day la thoi diem tot de co mot management tool
- **Linux desktop market share** dang tang (4%+ global) — nhieu nguoi dung moi can tool de dam bao
- **Wayland adoption** gan hoan chinh — Hyprland la lua chon hang dau cho custom Wayland desktop
- **Chua co dominant tool** trong Hyprland ecosystem — HCC co the tro thanh "the standard way to install Hyprland desktops"

**Risks:**
1. **Chi tested tren Arch** — can test tren Fedora, Ubuntu, OpenSUSE de xac nhan PM abstraction
2. **Single contributor** — bus factor = 1, can them maintainers
3. **Bash codebase** — kho maintain khi scale, can refactor sang language khac cho v2.0
4. **Competition tu dotfiles managers** — chezmoi, yadav dang phat trien nhanh
5. **Hyprland stability** — breaking changes tu Hyprland updates co the gay incompatibility

**Verdict:**
HCC van con som de goi la "production-ready cho moi nguoi" nhung da du cho daily use tren Arch Linux. Feature set hien tai (TUI, 9 PMs, AI, rollback, 10 community profiles, Flatpak) dap ung du nhu cau cua phan lon Hyprland users. Thieu hut chinh la non-Arch testing va test coverage. Day la thoi diem thich hop de promote cho community va thu feedback.

---

## 14. Development Principles

```
Read → Understand → Design → Implement → Test → Log → Continue
```

- Never skip layers
- Never refactor blindly
- Desktop installation must remain functional during refactoring
- Prefer completing existing abstractions over creating new ones
- Do not replace working pipelines
- Refactor incrementally
- Every architectural decision must preserve Desktop Install functionality
