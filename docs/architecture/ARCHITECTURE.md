# Hyprland Control Center Architecture

## Layers

CLI

↓

Dispatcher

↓

Modules

↓

Services

↓

Libraries

↓

Renderers

↓

Executors

---

## Responsibilities

### bin/

Entry point.

### dispatcher

Route CLI command.

### modules/

Receive CLI request.

No business logic.

### services/

Business logic.

### lib/

Reusable functions.

### renderers/

Only render output.

### analysis/

External repository research.

### themes/

Desktop package manifests.

### plugins/

Plugin manifests.

---

## Rules

1. Modules must never contain business logic.
2. Services may call libraries.
3. Libraries must never print UI.
4. Renderers must never install software.
5. Executors never parse manifests.