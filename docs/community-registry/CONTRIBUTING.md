# Community Registry — How to Add Your Desktop

1. Fork `laosifu/Hyprland-Control-Center` on GitHub
2. Edit `docs/community-registry/registry.txt`:
   ```
   Name|https://github.com/you/your-dotfiles|Short description
   ```
3. Submit a Pull Request

## Format

```
Desktop Name|git-url|Short description (max 100 chars)
```

## Requirements

Your repo must contain:
- `hcc.manifest` — metadata
- `package.toml` — package definitions (or legacy `package.conf`)
- `payload/` — config files (optional)

## Verification

```bash
hcc desktop install https://github.com/you/your-dotfiles
```

Test before submitting!
