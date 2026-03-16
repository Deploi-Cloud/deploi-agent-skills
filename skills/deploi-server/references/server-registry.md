# Server Registry: deploi-servers.json

Every server created through this skill gets its credentials stored in `deploi-servers.json` (same directory as `.env`). This file is the source of truth for AI agents that need to access, configure, or deploy to any Deploi server later.

## Format

```json
{
  "servers": {
    "my-project-server": {
      "ip": "193.69.50.148",
      "username": "cursor",
      "password": "the-sudo-password",
      "os": "Ubuntu 24.04",
      "ram": 4,
      "cpu": 2,
      "disk": 40,
      "created": "2026-03-12",
      "apps": []
    }
  }
}
```

**This file must be gitignored** — it contains passwords. Add `deploi-servers.json` to `.gitignore` if not already present.

## Fields

- `ip`: Server public IP (empty until provisioning completes, then updated via GetServerInfo)
- `username`: Always `"cursor"` (Deploi AI-Server convention)
- `password`: The generated sudo password for this server
- `os`: Operating system used at creation
- `ram`, `cpu`, `disk`: Server specs
- `created`: Date of creation (YYYY-MM-DD)
- `apps`: Array of deployed app names — updated when apps are deployed

## Server Directory Conventions

All Deploi servers follow this directory structure:

```
/home/cursor/                  ← home directory (user: cursor)
├── apps/                      ← all deployed applications live here
│   ├── my-web-app/            ← one directory per app
│   │   ├── .env               ← app-specific environment variables
│   │   └── ...                ← app source / docker-compose / etc.
│   └── api-backend/
│       ├── .env
│       └── ...
├── backups/                   ← manual backups, database dumps
└── scripts/                   ← utility scripts (deploy helpers, cron jobs)
```

**Rules for deploying apps:**
- Each app gets its own directory under `/home/cursor/apps/<app-name>/`
- App-specific secrets go in the app's own `.env` file, not in a global location
- When deploying a new app, update `deploi-servers.json` locally — add the app name to that server's `"apps"` array
- Use systemd services or Docker for long-running processes — never rely on background shell processes
- Nginx configs go in `/etc/nginx/sites-available/` with symlinks in `sites-enabled/` (standard pattern)

## Credentials & Config Files Summary

| File | Purpose | Contains secrets? |
|------|---------|-------------------|
| `.env` | Deploi account credentials (login email + password) | Yes |
| `deploi-servers.json` | Per-server registry: IP, username, sudo password, specs, deployed apps | Yes |
| `~/.ssh/config` | SSH connection shortcuts (no secrets — references key file) | No |

Both `.env` and `deploi-servers.json` must be gitignored. Never commit credentials.
