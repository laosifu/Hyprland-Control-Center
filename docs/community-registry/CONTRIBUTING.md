# Community Registry — How to Add Your Desktop

1. Fork `hyprland-control-center/community-registry` on GitHub
2. Add your desktop entry to `registry.txt`:
   ```
   Name|https://github.com/you/your-dotfiles|Short description
   ```
3. Submit a Pull Request

## Format

```
Desktop Name|git-url|Short description (max 100 chars)
```

## Requirements

Your repo must have:
- `hcc.manifest` — metadata
- `package.toml` — package definitions (or legacy `package.conf`)
- `payload/` — config files (optional)

## Verification

```bash
hcc desktop install https://github.com/you/your-dotfiles
```

Test before submitting!
