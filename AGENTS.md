# Deploi Agent Skills

This repository contains AI agent skills for provisioning and managing VPS servers at [Deploi.no](https://deploi.no) — Norwegian cloud hosting built for AI agents.

## Available Skills

### deploi-server
**Location:** `skills/deploi-server/SKILL.md`

Use when the user wants to create a new Deploi VPS server. Handles authentication, server configuration, SSH setup, and connection.

**Triggers:** "create a server", "I need a VPS", "set up Deploi", "provision a server", mentions of deploi.no

### deploi-ops
**Location:** `skills/deploi-ops/SKILL.md`

Use for everything after server creation: deploying apps, managing domains & DNS, SSL/HTTPS, firewalls, databases, billing, and all server administration.

**Triggers:** "deploy", "domain", "DNS", "SSL", "HTTPS", "firewall", "database", "billing", "restart server", "monitor CPU"

## Skill Relationship

`deploi-server` creates servers. `deploi-ops` manages them. A user typically needs `deploi-server` first, then `deploi-ops` for ongoing work. If `deploi-ops` detects no servers exist, it should direct to `deploi-server`.

## Requirements

- **Node.js** — required for API calls (the Deploi API blocks curl)
- **SSH** — required for server access
- **Deploi account** — register at [kundepanel.deploi.no](https://kundepanel.deploi.no)

## Credential Files

Both `.env` and `deploi-servers.json` contain secrets and must be gitignored. Never commit credentials.
