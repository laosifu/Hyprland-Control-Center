# Hyprland Control Center

## Architecture v1.0

Status:

Frozen

---

# Philosophy

HCC is not a shell script.

HCC is a modular desktop package manager for Hyprland environments.

Every feature must be implemented as reusable components.

Business logic must never live inside the CLI entry point.

---

# Layers

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

Operating System

---

# Layer Responsibilities

## bin/

Entry point only.

Allowed:

- bootstrap
- initialize
- dispatch

Forbidden:

- filesystem
- git
- package install
- parsing manifests

---

## dispatcher

Routes CLI commands.

No business logic.

---

## modules/

Implements CLI commands.

Examples

doctor

theme install

plugin install

desktop install

Responsibilities

- parse CLI
- call services
- print result

Must not

- copy files
- clone repositories
- install packages

---

## services/

Workflow orchestration.

Examples

Desktop installation

Theme installation

Plugin installation

Backup workflow

A service combines multiple libraries.

---

## lib/

Reusable engines.

Examples

filesystem

manifest

planner

packages

logger

renderers

A library must never call modules.

A library must never know about CLI.

---

## themes/

Theme definitions.

Contains metadata only.

---

## plugins/

Plugin definitions.

Contains metadata only.

---

## analysis/

Research only.

Never executed.

---

## docs/

Documentation only.

Never executed.

---

# Dependency Rules

Allowed

bin

↓

dispatcher

↓

modules

↓

services

↓

libraries

Forbidden

library

↓

module

library

↓

dispatcher

service

↓

dispatcher

---

# Naming

run_xxx()

Module entry

filesystem_xxx()

Filesystem engine

manifest_xxx()

Manifest engine

planner_xxx()

Planner

render_xxx()

Renderer

---

# Bootstrap

bin/hcc

↓

lib/bootstrap.sh

↓

services/bootstrap.sh

↓

modules/bootstrap.sh

---

# Testing

Every new engine must be tested independently.

Every service must be tested independently.

Every module must be tested through hcc.

---

# Future

Filesystem Engine

Git Engine

Package Engine

Rollback Engine

Executor

Desktop Installer

Theme Installer

Plugin Installer