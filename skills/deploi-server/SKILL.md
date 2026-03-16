---
name: deploi-server
description: >
  Provision and manage Deploi VPS servers: authenticate via API,
  create servers with SSH access, and connect. Use when the user mentions Deploi,
  wants a Norwegian cloud VPS, or asks to create/manage a server at deploi.no.
compatibility: Requires Node.js and SSH. Works with Claude Code, Cursor, Codex, and similar agents.
allowed-tools: Bash Read Write Edit Grep
metadata:
  author: deploi
  version: "1.0"
  website: https://deploi.no
---

# Deploi Server — AI Agent Skill

When this skill is invoked, display this banner to the user:

```
    ◇
   ◇ ◇        ____             _       _
  ◇   ◇      |  _ \  ___ _ __ | | ___ (_)
 ◇     ◇     | | | |/ _ \ '_ \| |/ _ \| |
  ◇   ◇      | |_| |  __/ |_) | | (_) | |
   ◇ ◇       |____/ \___| .__/|_|\___/|_|
    ◇                    |_|
  ◇ ◇        Norwegian Cloud VPS
 ◇   ◇       deploi.no
  ◇ ◇
```

This skill guides an AI agent through provisioning a VPS at Deploi.no:
authentication, server creation, IP retrieval, SSH configuration, and connection.

**API endpoint:** `https://api.deploi.no`
**Method:** POST with `Content-Type: application/json` for all commands.

> **IMPORTANT:** All API calls MUST use Node.js `https` module — NOT `curl`.
> The API blocks `curl` requests for authenticated commands (returns 403 / "Request blocked").

For the Node.js API call pattern and error reference, see `references/api-helper.md`.
For the `deploi-servers.json` registry format and server conventions, see `references/server-registry.md`.

---

## Phase 1: Credentials & Environment Check

Read the project's `.env` file and check for ALL of these:

| Variable | Required | Purpose |
|----------|----------|---------|
| `DEPLOI_USERNAME` | Yes | Login email |
| `DEPLOI_ACCOUNT_PASSWORD` | Yes | Account password |

**If `DEPLOI_USERNAME` and `DEPLOI_ACCOUNT_PASSWORD` exist**, proceed to Phase 2.

**If missing**, tell the user:

> Du trenger en Deploi-konto for å fortsette. Registrer deg på **kundepanel.deploi.no** og oppgi e-post og passord her etterpå.
>
> You need a Deploi account to continue. Register at **kundepanel.deploi.no** and provide your email and password here afterwards.

Save credentials to `.env` once provided. **Do not attempt to register accounts via API.**

Check if `deploi-servers.json` exists. If not, it will be created during Phase 5.

---

## Phase 2: Authentication

Obtain a fresh token before any authenticated API call. Tokens expire — never store them in `.env`.

**Login payload:**
```json
{
  "command": "Login",
  "username": "<DEPLOI_USERNAME from .env>",
  "password": "<DEPLOI_ACCOUNT_PASSWORD from .env>"
}
```

Extract and keep in memory for the session:
- `data.token` → use for all authenticated API calls
- `data.clients[0].id` → use as `clientid`

**If `data.nextstep` is not `"none"`**, the user needs to complete additional steps (e.g., 2FA) — inform them.

**Error handling:**
- `"Email or Password Invalid"` (messageId -1) → credentials are wrong, ask user to verify
- `"Request blocked"` (messageId 138) → you are using curl instead of Node.js, switch to the helper pattern

---

## Phase 3: SSH Key Preparation (MANDATORY)

**The SSH key is the primary and preferred access method. Do NOT proceed to server creation without it.**

### Step 1: Check for existing key

```bash
test -f ~/.ssh/id_ed25519 && echo "EXISTS" || echo "NOT_FOUND"
```

### Step 2: If key does NOT exist

Tell the user and offer to help:

> Jeg fant ingen SSH-nøkkel (`~/.ssh/id_ed25519`). Du trenger en for å koble til serveren sikkert.
> Skal jeg generere en for deg?
>
> No SSH key found at `~/.ssh/id_ed25519`. You need one to connect securely to the server.
> Want me to generate one for you?

**If the user agrees**, generate:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```

**If the user has a key elsewhere**, ask for the path and use that instead.

### Step 3: Read and store the public key

```bash
cat ~/.ssh/id_ed25519.pub
```

Keep the full public key contents in memory — it will be sent with the server creation request.

**STOP HERE if no SSH key is available. Do not proceed without it.**

---

## Phase 4: Needs Assessment & Server Proposal (Mandatory User Approval)

**Never create a server without explicit user approval of the spec and price.**

### Step 1: Understand the user's needs

Ask about their use case — you don't need to ask all of these, just enough to make a good recommendation:

- **What will you use the server for?** (web app, database, API backend, dev/testing, game server, etc.)
- **What tech stack?** (Node.js, Python/Django, Docker, WordPress, PostgreSQL, etc.)
- **How much traffic/users do you expect?**
- **Do you need a specific OS?** (default is Ubuntu 24.04)
- **Any specific storage needs?**

If the user already knows exactly what they want, skip the questions and go straight to the proposal.

**Guidance:**
- **Simple web app / API:** Testing package (1 GB RAM) is usually enough to start
- **Docker + database + app:** Core package (4 GB RAM) recommended
- **Multiple services / heavier workloads:** Custom config with 8+ GB RAM
- **Just experimenting / learning:** Testing package is perfect

### Step 2: Present packages and pricing

| Package | RAM | vCPU | SSD | Price/month |
|---------|-----|------|-----|-------------|
| Testing | 1 GB | 1 | 10 GB | ~131 NOK |
| Core | 4 GB | 2 | 40 GB | ~332 NOK |

**Resource prices** (for custom configurations):
- RAM: **25 NOK/GB/month**
- vCPU (Linux): **96 NOK/vCPU/month**
- SSD: **1 NOK/GB/month**

**Resource limits** (API-enforced): RAM 1–160 GB, vCPU 1–80, SSD 5–10,000 GB (1 disk only)

### Step 3: Present a clear proposal

> **Foreslått server:** 4 GB RAM, 2 vCPU, 40 GB SSD, Ubuntu 24.04
> **Tilgang:** SSH-nøkkel (passordinnlogging deaktivert)
> **Estimert pris:** 332 NOK/måned (eks. mva)
> **Godkjenner du dette oppsettet og prisen?** Jeg sender bestillingen først etter din bekreftelse.

### Step 4: Wait for explicit approval

If the user wants changes, adjust and re-propose.

---

## Phase 5: Pre-flight Checks & Server Creation

### Step 1: Verify SSH key is ready

Re-confirm the public key is available. If not, go back to Phase 3.

### Step 2: Check for duplicate server names

**The API allows duplicate server names and will create a billable server regardless.** Always check first:

Call `GetServers` and verify the chosen name does not already exist. If it does, ask the user for a different name.

### Step 3: Generate server password

The API **requires** a password even when using SSH key authentication. This becomes the sudo password.

**Generate a unique password for THIS server:**

```bash
node -e "const c='abcdefghijklmnopqrstuvwxyz',C='ABCDEFGHIJKLMNOPQRSTUVWXYZ',n='0123456789',a=c+C+n;let p=c[Math.random()*26|0]+C[Math.random()*26|0]+n[Math.random()*10|0];for(let i=0;i<13;i++)p+=a[Math.random()*a.length|0];console.log(p.split('').sort(()=>Math.random()-.5).join(''))"
```

### Step 4: Final checklist before API call

- [ ] SSH public key is read and ready
- [ ] Server password has been generated (in memory)
- [ ] Server name does not already exist (checked via GetServers)
- [ ] User has explicitly approved the spec and price
- [ ] RAM, CPU, and disk are within API limits

### Step 5: Create the server

**CreateVirtualServer payload:**
```json
{
  "command": "CreateVirtualServer",
  "token": "<from Login>",
  "clientid": "<from Login, e.g. 928>",
  "name": "<server-name>",
  "ram": 4,
  "cpu": 2,
  "disks": [
    {
      "idSet": false, "id": "", "name": "root", "size": 40, "type": "ssd",
      "backupSpecs": {
        "profileIdSet": false, "profileId": 0,
        "spec": [{ "loc": 1, "daily": 10, "weekly": 0, "monthly": 0, "yearly": 0 }]
      }
    }
  ],
  "OS": "Ubuntu 24.04",
  "licenses": [],
  "username": "cursor",
  "password": "<generated password>",
  "publickey": "<contents of ~/.ssh/id_ed25519.pub>",
  "allowRemotePasswordLogin": false,
  "publicip": true
}
```

**Allowed OS values:** `"Ubuntu 24.04"`, `"Ubuntu 22.04"`, `"Debian 12"`, `"Debian 13"`, `"Fedora 34"`, `"Suse 15.1"`, `"CentOS 8.2"`, `"AlmaLinux 9.0"`, `"Windows Server 2019 Datasenter"`, `"Windows Server 2022 Datasenter"`, `"Windows Server 2025 Datasenter"`

**Success response:** `{ "success": true, "message": "Server created.", "messageId": 80 }`

### Step 6: Save server credentials

**Immediately after successful creation**, save to `deploi-servers.json` (see `references/server-registry.md` for format). Also add `deploi-servers.json` to `.gitignore` if not already present.

**Field notes:**
- `clientid`: number (from Login)
- `username`: always `"cursor"` (Deploi AI-Server convention)
- `publickey`: full contents of the `.pub` file — **must be provided**
- `allowRemotePasswordLogin`: always `false` (unless user explicitly requests password login)
- `password`: required by API even with SSH key — used as sudo password
- `name`: use a descriptive, lowercase, hyphenated name (e.g. `"my-project-server"`)

---

## Phase 6: Get Server IP

The server takes 30–120 seconds to provision. Poll for the IP.

**Step 1 — GetServers:**
```json
{ "command": "GetServers", "token": "<token>", "clientid": "<clientid>" }
```

Find your server by `name`. If multiple match (shouldn't happen), use highest `id`.

**Step 2 — GetServerInfo:**
```json
{ "command": "GetServerInfo", "token": "<token>", "id": "<server id>" }
```

The public IP is at `serverInfo.virtual.mainip`.

**Retry logic:** If `mainip` is empty, `"0.0.0.0"`, or status is not `"active"`, wait 15 seconds and retry. Up to 8 retries (2 minutes total). If still no IP, tell the user to check kundepanel.deploi.no.

**Step 3 — Update `deploi-servers.json` with the IP.**

---

## Phase 7: SSH Config

Add the server to `~/.ssh/config`. Check first that no `Host <server-name>` block already exists.

```
Host <server-name>
  HostName <server-ip>
  User cursor
  IdentityFile ~/.ssh/id_ed25519
```

**Do not overwrite** existing entries.

---

## Phase 8: Connect to Server

Tell the user:

> **Serveren er klar!** Koble til for å begynne å jobbe på den.
>
> - **VS Code / Cursor:** Trykk F1 → «Remote-SSH: Connect to Host» → velg **<server-name>**
> - **Claude Code:** `claude --ssh <server-name>`
> - **Terminal:** `ssh <server-name>`
>
> Gå til server-konteksten og si hva du vil gjøre videre.

**Wait for the user to connect.** Do not attempt server-side work in this local context.

---

## Working with Existing Servers

When a user wants to work with an existing server:

1. **Read `deploi-servers.json`** to see all available servers
2. **Look up credentials** — IP, username, password (for sudo) are all in the registry
3. **Connect via SSH** — use the config entry or `ssh cursor@<ip>`

The password from `deploi-servers.json` is the sudo password on the server.
