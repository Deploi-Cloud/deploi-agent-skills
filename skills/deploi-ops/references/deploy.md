# Deploy App End-to-End

The flagship workflow — from "I have code" to "live at my-domain.no with HTTPS."

## Step 1: Pick a Server

Read `deploi-servers.json` to see what exists:

```json
{
  "servers": {
    "my-server": {
      "ip": "193.69.50.148",
      "username": "cursor",
      "password": "...",
      "os": "Ubuntu 24.04",
      "ram": 4, "cpu": 2, "disk": 40,
      "created": "2026-03-12",
      "apps": ["existing-app"]
    }
  }
}
```

**Decision framework:**
- Server has <3 apps and headroom → use it
- Server is overloaded or user wants isolation → create new via `deploi-server` skill
- No servers exist → create one first

Show the user what's available and which server you recommend.

## Step 2: Detect Stack

Auto-detect by looking at the project files:

| File | Stack | Deploy Method |
|------|-------|---------------|
| `package.json` | Node.js | npm install, PM2/systemd |
| `requirements.txt` / `pyproject.toml` | Python | venv, gunicorn/uvicorn + systemd |
| `docker-compose.yml` / `Dockerfile` | Docker | docker compose up -d |
| `go.mod` | Go | Build binary, systemd |
| `Cargo.toml` | Rust | Build binary, systemd |
| `composer.json` | PHP | PHP + Nginx, composer install |
| `Gemfile` | Ruby | bundle install, Puma + systemd |
| Static HTML/CSS/JS only | Static | Nginx serving files directly |

If unclear, ask the user.

## Step 3: Deploy

All apps go under `/home/cursor/apps/<app-name>/` on the server.

**Node.js app:**
```bash
# On the server (via SSH)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
mkdir -p ~/apps/<app-name> && cd ~/apps/<app-name>
git clone <repo-url> .
npm install --production
# Set up PM2 or systemd (see process management below)
```

**Docker app:**
```bash
sudo apt update && sudo apt install -y docker.io docker-compose-v2
sudo usermod -aG docker cursor && newgrp docker
mkdir -p ~/apps/<app-name> && cd ~/apps/<app-name>
# Copy docker-compose.yml and .env
docker compose up -d
```

**Static site:**
```bash
sudo apt install -y nginx
sudo mkdir -p /var/www/<app-name>
# Copy files to /var/www/<app-name>
# Configure Nginx (see ssl-https.md for full template)
```

## Step 4: Domain + DNS

If the user wants a custom domain:

1. **Check availability** (no auth needed):
```json
{ "command": "DomainAvailable", "domain": "example.no" }
```

2. **Check pricing** (no auth needed):
```json
{ "command": "GetDomainPrice", "domain": "example.no" }
```

3. **Register if needed** — see `domains-dns.md`

4. **Add DNS records** — point domain to server IP:
```json
{ "command": "AddDomainRecord", "token": "<t>", "domainname": "example.no", "type": "A", "host": "@", "value": "<server-ip>", "ttl": 3600 }
```
```json
{ "command": "AddDomainRecord", "token": "<t>", "domainname": "example.no", "type": "A", "host": "www", "value": "<server-ip>", "ttl": 3600 }
```

5. Wait for DNS propagation (check with `dig example.no`)

## Step 5: SSL/HTTPS

See `ssl-https.md` for the full recipe.

## Step 6: Verify

```bash
# On the server
curl -I https://example.no
```

Confirm HTTPS works, then update `deploi-servers.json` locally — add the app to the server's `apps` array.

## Backup Strategy

**Deploi disk backups:** Configured at server creation (`daily: 10` by default = 10 daily snapshots).

**App-level backups (recommended in addition):**
```bash
# PostgreSQL daily dump
pg_dump -U myappuser myappdb > ~/backups/myappdb-$(date +%Y%m%d).sql

# Cron job for automated backups
crontab -e
# Add: 0 3 * * * pg_dump -U myappuser myappdb > /home/cursor/backups/myappdb-$(date +\%Y\%m\%d).sql
```

**Before big changes:** Always back up first:
```bash
mkdir -p ~/backups
cp -r ~/apps/<app-name> ~/backups/<app-name>-$(date +%Y%m%d)
```
