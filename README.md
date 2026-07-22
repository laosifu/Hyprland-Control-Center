# Hyprland Control Center

HCC is a Bash deployment framework for Hyprland desktop packages on Arch,
EndeavourOS and CachyOS.

## Available commands

- `hcc doctor` — report the current desktop environment.
- `hcc cleanup` — report cache locations and their sizes.
- `hcc backup` — create a timestamped configuration snapshot with metadata.
- `hcc restore [backup-id]` — list snapshots or restore one after confirmation.
- `hcc inventory` — inspect system components.
- `hcc desktop install <name>` — preview, validate and install a desktop package.
- `hcc profile <list|status>` — show installed desktop profiles and the active profile.
- `hcc theme <list|install|uninstall> [name]`.
- `hcc plugin <install|uninstall> <name>` and `hcc plugins`.

Desktop packages define package-manager dependencies, AUR dependencies, Git
repositories and package-owned payloads. HCC validates the package and its
copy sources before execution, supports dry-run at the execution layer, and
registers rollback operations for created directories and cloned repositories.

`analysis/` is research-only. Runtime payloads belong in `desktop-packages/`.

Each successful desktop installation records a local profile in
`~/.local/share/hcc/profiles/`, including its source, version, pre-install
snapshot and deployment ownership plan. This is the state foundation for safe
profile switching, updates and rollback.
