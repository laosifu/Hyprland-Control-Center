# HCC Release Guide

## 1. Create Community Registry Repo

The community registry lets users discover desktops via `hcc desktop search`.

### Steps

1. Go to https://github.com/new
2. Create repo: `hyprland-control-center/community-registry`
   - Owner: `hyprland-control-center` (create org first) or your personal account
   - Repo name: `community-registry`
   - Public
   - Initialize with README

3. Clone and add registry file:
```bash
git clone https://github.com/<you>/community-registry
cd community-registry
cp /path/to/Hyprland-Control-Center/docs/community-registry/registry.txt .
git add registry.txt
git commit -m "init: add initial registry entries"
git push
```

4. Verify:
```bash
curl -sL https://raw.githubusercontent.com/<you>/community-registry/main/registry.txt
```

5. Update HCC's default URL in `lib/desktop_registry.sh:1064`:
```bash
# Change this line:
HCC_COMMUNITY_REGISTRY_URL="https://raw.githubusercontent.com/<you>/community-registry/main/registry.txt"
```

---

## 2. Publish AUR Packages

### Prerequisites

- Arch Linux (or AUR access)
- `ssh-keygen` and SSH key registered at https://aur.archlinux.org
- `base-devel` installed

### hcc-bin (stable release)

```bash
# 1. Clone the AUR repo
git clone ssh://aur@aur.archlinux.org/hcc-bin.git
cd hcc-bin

# 2. Copy PKGBUILD and install script
cp /path/to/Hyprland-Control-Center/dist/aur/hcc-bin/PKGBUILD .
cp /path/to/Hyprland-Control-Center/dist/aur/hcc-bin/hcc.install .

# 3. Update checksums
rm -f PKGBUILD
updpkgsums

# 4. Test build
makepkg -si

# 5. Generate .SRCINFO
makepkg --printsrcinfo > .SRCINFO

# 6. Commit and push
git add PKGBUILD hcc.install .SRCINFO
git commit -m "hcc-bin v0.8.0"
git push
```

### hcc-git (git version)

```bash
# 1. Clone the AUR repo
git clone ssh://aur@aur.archlinux.org/hcc-git.git
cd hcc-git

# 2. Copy PKGBUILD and install script
cp /path/to/Hyprland-Control-Center/dist/aur/hcc-git/PKGBUILD .
cp /path/to/Hyprland-Control-Center/dist/aur/hcc-git/hcc.install .

# 3. Generate .SRCINFO (no checksums needed for git packages)
makepkg --printsrcinfo > .SRCINFO

# 4. Test build
makepkg -si

# 5. Commit and push
git add PKGBUILD hcc.install .SRCINFO
git commit -m "hcc-git v0.8.0"
git push
```

### Verify AUR packages

```bash
# After pushing, wait a few minutes, then:
yay -S hcc-bin
# or
paru -S hcc-git

# Test
hcc doctor
hcc --version
```

---

## 3. Tag a Release on GitHub

```bash
# After all changes are committed and pushed:
git tag -a v0.8.0 -m "v0.8.0"
git push origin v0.8.0
```

Then create a Release on GitHub:
1. Go to https://github.com/laosifu/Hyprland-Control-Center/releases
2. Click "Create a new release"
3. Choose tag `v0.8.0`
4. Title: `v0.8.0`
5. Description: Summarize changes
6. Publish

---

## 4. Verify Everything

```bash
# Test community registry search
hcc desktop search hypr

# Test AUR install
yay -S hcc-bin
hcc doctor

# Test profile get
hcc get end-4

# Run tests
bash tests/run_all.sh
bash tests/run_cli_tests.sh
```
