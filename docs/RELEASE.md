# HCC Release Guide

## 1. Publish AUR Packages

### Prerequisites

- Arch Linux
- AUR account: https://aur.archlinux.org/register/
- SSH key added to AUR: https://aur.archlinux.org/account/
- SSH key loaded: `ssh-add ~/.ssh/id_rsa`

### Quick deploy (automated script)

```bash
# The script clones AUR repos, copies files, generates .SRCINFO,
# and shows the final git push command. You run the push yourself.

bash scripts/deploy-aur.sh all
```

### Manual deploy

#### hcc-bin (stable)

```bash
git clone ssh://aur@aur.archlinux.org/hcc-bin.git
cd hcc-bin
cp /path/to/HCC/dist/aur/hcc-bin/PKGBUILD .
cp /path/to/HCC/dist/aur/hcc-bin/hcc.install .
cp /path/to/HCC/dist/aur/hcc-bin/.SRCINFO .
git add PKGBUILD hcc.install .SRCINFO
git commit -m "hcc-bin v0.8.0"
git push
```

#### hcc-git (dev)

```bash
git clone ssh://aur@aur.archlinux.org/hcc-git.git
cd hcc-git
cp /path/to/HCC/dist/aur/hcc-git/PKGBUILD .
cp /path/to/HCC/dist/aur/hcc-git/hcc.install .
cp /path/to/HCC/dist/aur/hcc-git/.SRCINFO .
git add PKGBUILD hcc.install .SRCINFO
git commit -m "hcc-git v0.8.0"
git push
```

### Verify

```bash
yay -S hcc-bin
hcc --version
hcc doctor
```

---

## 2. Tag a Release on GitHub

```bash
git tag -a v0.8.0 -m "v0.8.0"
git push origin v0.8.0
```

Then create a Release on GitHub:
1. Go to https://github.com/laosifu/Hyprland-Control-Center/releases
2. Click "Create a new release"
3. Choose tag `v0.8.0`
4. Title: `v0.8.0`
5. Description: Summarize changes since last release
6. Publish

---

## 3. Add to Community Registry

Edit `docs/community-registry/registry.txt` and add entries for new profiles.
Submit a PR to https://github.com/laosifu/Hyprland-Control-Center.

Community registry URL (auto-fetched by `hcc desktop search`):
```
https://raw.githubusercontent.com/laosifu/Hyprland-Control-Center/main/docs/community-registry/registry.txt
```

---

## 4. Verify Everything

```bash
bash tests/run_all.sh
bash tests/run_cli_tests.sh
hcc desktop search hypr
hcc get end-4
```
