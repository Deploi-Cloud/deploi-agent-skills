# Contributing to Deploi Agent Skills

We welcome contributions! Whether it's improving existing skills, proposing new ones, or fixing typos — all help is appreciated.

## How to Contribute

1. **Fork** this repository
2. **Create a branch** for your changes (`git checkout -b my-skill-improvement`)
3. **Make your changes** — edit existing skills or add new ones
4. **Test** your changes by giving the skill file to an AI agent and verifying it works
5. **Submit a Pull Request** with a clear description of what you changed and why

## Proposing New Skills

Have an idea for a new Deploi skill? Open an issue describing:

- **What the skill does** — what task or workflow does it enable?
- **Who it's for** — what kind of user or use case benefits?
- **API commands involved** — which Deploi API endpoints does it use (if any)?

We'll discuss the proposal in the issue before you start writing.

## Skill File Format

Skills are markdown files with YAML frontmatter:

```markdown
---
name: skill-name
description: >
  One-line description of what the skill does and when to trigger it.
---

# Skill Title

Skill content here...
```

Keep skills self-contained — an AI agent should be able to follow the skill without needing external documentation.

## Compensation

Contributors receive **free Deploi server credits** as payment for their work. This applies to:

- **Skill contributions** — new skills, improvements, bug fixes
- **Experience sharing** — if you share your experience using Deploi with AI agents and we feature it on the Deploi blog, you'll receive server credits as well

## Contact

- **Email:** Greger@deploi.no
- **Phone:** +47 928 45 280

Questions? Reach out — we're happy to help.
