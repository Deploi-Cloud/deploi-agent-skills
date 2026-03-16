# Deploi Agent Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Norwegian Cloud](https://img.shields.io/badge/%F0%9F%87%B3%F0%9F%87%B4-Norwegian%20Cloud-red)](https://deploi.no)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-Standard-green)](https://agentskills.io)

**AI Agent Skills for provisioning and managing VPS servers at [Deploi](https://deploi.no) — Norwegian cloud hosting built for AI agents.**

Give these skills to your AI coding agent (Claude Code, Cursor, Windsurf, Codex, etc.) and let it create servers, deploy apps, set up domains, SSL, databases, and more — all through the Deploi API.

---

## Skills

| Skill | Description |
|-------|-------------|
| [deploi-server](skills/deploi-server/SKILL.md) | Provision a VPS, generate SSH keys, configure access, and connect |
| [deploi-ops](skills/deploi-ops/SKILL.md) | Deploy apps, manage domains & DNS, SSL/HTTPS, firewalls, databases, billing |

**deploi-server** handles everything up to a running server with SSH access.
**deploi-ops** takes over from there — deploying code, pointing domains, setting up HTTPS, and day-to-day server management.

---

## Installation

### Quick Install (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/Deploi-Cloud/deploi-agent-skills/main/scripts/install.sh | bash
```

The install script auto-detects your environment (Claude Code, Cursor, or generic) and places skills in the right location.

### Claude Code Plugin

```bash
claude plugin add Deploi-Cloud/deploi-agent-skills
```

### Manual Install

Clone or download, then copy the `skills/` directory into your project:

```bash
git clone https://github.com/Deploi-Cloud/deploi-agent-skills.git
cp -r deploi-agent-skills/skills/ .claude/skills/   # Claude Code
# or
cp -r deploi-agent-skills/skills/ .cursor/rules/     # Cursor
```

---

## Repo Structure

```
skills/
├── deploi-server/
│   ├── SKILL.md                  # Server provisioning (main skill)
│   └── references/
│       ├── api-helper.md         # API call pattern & error reference
│       └── server-registry.md    # deploi-servers.json format & conventions
├── deploi-ops/
│   ├── SKILL.md                  # Server management & deployment (main skill)
│   └── references/
│       ├── deploy.md             # App deployment workflows
│       ├── domains-dns.md        # Domain & DNS management
│       ├── ssl-https.md          # SSL/HTTPS setup (Certbot + Nginx)
│       ├── firewall.md           # Firewall (UFW + managed)
│       ├── databases.md          # Database workflows (PostgreSQL, MySQL)
│       └── billing.md            # Email, invoices, other services
scripts/
└── install.sh                    # Auto-detect & install script
.claude-plugin/
└── plugin.json                   # Claude Code plugin manifest
AGENTS.md                         # Agent discovery file
```

---

## Getting Started

1. **Sign up** at [deploi.no](https://deploi.no) (or [kundepanel.deploi.no](https://kundepanel.deploi.no))
2. **Install** the skills using one of the methods above
3. **Tell your AI agent** to create a Deploi server — it handles the rest

That's it. Your agent will walk you through authentication, server configuration, and connection.

---

## Links

- [Deploi AI Skills](https://deploi.no/ai-skills) — learn more about AI-powered server management
- [Deploi AI Server](https://deploi.no/server/ai-server) — servers optimized for AI agents
- [Customer Panel](https://kundepanel.deploi.no) — manage your account and servers
- [API Docs](https://api.deploi.no/api-docs) — Deploi API reference
- [Agent Skills Standard](https://agentskills.io) — the open standard this repo follows

---

## License

[MIT](LICENSE) — see the LICENSE file for details.
