---
name: deploi-ops
description: "Everything after server creation on Deploi VPS: deploy applications, manage domains, DNS records, SSL certificates, HTTPS setup, firewall configuration, server restart, CPU monitoring, databases, email services, billing, invoices. Use when the user wants to deploy code to a Deploi server, register or configure domains, set up DNS, get SSL/HTTPS working, manage firewalls, check server status, restart servers, monitor resources, install software, configure web servers, manage Docker containers, set up databases, or perform any server administration task on Deploi VPS. Also triggers for keywords: deploy, domain, DNS, SSL, certificate, HTTPS, firewall, monitoring, billing, email, restart, CPU, invoices, Deploi ops, server management."
---

# Deploi Ops — Server Management & Deployment

When this skill is invoked, display this banner:

```
    ◇
   ◇ ◇        ____             _       _
  ◇   ◇      |  _ \  ___ _ __ | | ___ (_)
 ◇     ◇     | | | |/ _ \ '_ \| |/ _ \| |
  ◇   ◇      | |_| |  __/ |_) | | (_) | |
   ◇ ◇       |____/ \___| .__/|_|\___/|_|
    ◇                    |_|
  ◇ ◇        Ops — Deploy & Manage
 ◇   ◇       deploi.no
  ◇ ◇
```

This skill handles **everything after server creation**: deploying apps, domains & DNS,
SSL/HTTPS, firewalls, monitoring, databases, and all server administration on Deploi VPS.

**Prerequisites:**
- `.env` with `DEPLOI_USERNAME` and `DEPLOI_ACCOUNT_PASSWORD` (Deploi account login)
- `deploi-servers.json` for server access (IP, username, per-server sudo password)

If `.env` is missing, refer user to `deploi-server` skill or kundepanel.deploi.no.
If `deploi-servers.json` is missing, the user needs to create a server first via the `deploi-server` skill.

**Credentials source:**
- **API auth:** `.env` → `DEPLOI_USERNAME` + `DEPLOI_ACCOUNT_PASSWORD`
- **Server sudo password:** `deploi-servers.json` → per-server `password` field (NOT `.env`)

---

## API Foundations

**Endpoint:** `https://api.deploi.no` — all commands use HTTP POST requests with a JSON body.

### Node.js API Helper

```bash
node -e "
const https = require('https');
const data = JSON.stringify(<PAYLOAD>);
const req = https.request('https://api.deploi.no', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(data) }
}, (res) => {
  let body = '';
  res.on('data', c => body += c);
  res.on('end', () => console.log(body));
});
req.write(data);
req.end();
"
```

### Authentication

Read `DEPLOI_USERNAME` and `DEPLOI_ACCOUNT_PASSWORD` from `.env`, then:

```json
{ "command": "Login", "username": "<email>", "password": "<password>" }
```

Extract `data.token` and `data.clients[0].id` from the response. Use these for all authenticated calls.

If any API call returns `messageId: 41` ("Not logged in"), the token has expired — re-authenticate.

### Complete API Command Reference

| Command | Auth | Required Params | Description |
|---------|------|-----------------|-------------|
| `Login` | No | `username`, `password` | Get token + clientid |
| `Logout` | Yes | `token` | Invalidate token |
| `GetUserInfo` | Yes | `token`, `clientid` | Account details |
| `GetServers` | Yes | `token`, `clientid` | List all servers |
| `GetServerInfo` | Yes | `token`, `id` | Server details (IP, specs) |
| `CreateVirtualServer` | Yes | `token`, `clientid`, + specs | Create new VPS |
| `RestartVirtualServer` | Yes | `token`, `id` | Restart a server |
| `DomainAvailable` | **No** | `domain` | Check domain availability |
| `GetDomainPrice` | **No** | `domain` | Get domain pricing |
| `GetDomains` | Yes | `token`, `clientid` | List owned domains |
| `GetDomainRecords` | Yes | `token`, `domainname` | List DNS records |
| `AddDomainRecord` | Yes | `token`, `domainname`, + record | Add DNS record |
| `DeleteDomainRecord` | Yes | `token`, `domainname`, `id` | Remove DNS record |
| `OrderDomain` | Yes | `token`, `clientid`, + details | Register/transfer domain |
| `GetFirewalls` | Yes | `token`, `clientid` | List managed firewalls |
| `CreateFirewall` | Yes | `token`, `clientid`, + config | Create managed firewall |
| `AddFirewallRule` | Yes | `token`, + rule | Add firewall rule |
| `OrderEmailService` | Yes | `token`, `clientid`, + config | Order email hosting |
| `GetInvoices` | Yes | `token`, `clientid` | List invoices |

---

## Routing: What Do You Need?

Based on the user's request, load the appropriate reference:

| User wants to... | Reference file |
|-------------------|---------------|
| Deploy an app end-to-end | `references/deploy.md` |
| Register/manage domains, DNS records | `references/domains-dns.md` |
| Set up SSL/HTTPS, Certbot, Nginx | `references/ssl-https.md` |
| Configure firewall (UFW or managed) | `references/firewall.md` |
| Install/manage databases (PostgreSQL, MySQL) | `references/databases.md` |
| Email, billing, invoices, other services | `references/billing.md` |

For server operations (restart, CPU monitoring, status checks, upgrade), see below.

---

## Server Operations via API

### Server Status Check

```json
{ "command": "GetServerInfo", "token": "<t>", "id": "<server-id>" }
```

Returns `serverInfo.virtual.mainip`, RAM, CPU, status, and more.

**Note:** Servers with `status: "off"` return `success: false`. `GetServers` still lists them.

### RestartVirtualServer

```json
{ "command": "RestartVirtualServer", "token": "<t>", "id": "<server-id>" }
```

Get `server-id` from `GetServers` (the `id` field, not the name).

**After restart:** Wait 30–60 seconds, then verify with `GetServerInfo` that status is `"active"`.


### Upgrade/Downgrade Server

```json
{ "command": "UpdateVirtualServer", "token": "<t>", "id": "<server-id>", "setCpu": true, "cpucent": cpucents, "setRam": false, "ram": gbram, "diskChange": [{"id": "<disk id>", "size": gbsize } ]}
```

Get `server-id` from `GetServers` (the `id` field, not the name).

**After upgrade/downgrade:** Wait 30–90 seconds, then verify with `GetServerInfo` that `running` is `true`.

### Logout

```json
{ "command": "Logout", "token": "<t>" }
```

---

## Decision Frameworks

### When to Create a New Server

| Situation | Recommendation |
|-----------|---------------|
| First app ever | Core (4 GB RAM, 2 CPU, 40 GB) — room to grow |
| Adding small side project | Use existing server if <3 apps and has headroom |
| Database needs isolation | Dedicated Start (1 GB) or Core (4 GB) |
| App gets heavy traffic | Dedicated server, possibly larger custom spec |
| Different OS needed | New server (can't change OS on existing) |
| Staging/dev environment | Start (1 GB) — cheap and disposable |

---

## Server Conventions

All Deploi VPS servers follow these conventions:

- **Username:** `cursor`
- **Auth:** SSH key (`~/.ssh/id_ed25519`) — password login disabled
- **Sudo password:** Per-server, stored in `deploi-servers.json`
- **OS:** Ubuntu 24.04 (default)
- **App directory:** `/home/cursor/apps/<app-name>/`
- **Backups:** `/home/cursor/backups/`

To connect: `ssh <server-name>` (uses the SSH config alias)

---

## Important Notes

- **Always ask before making changes** that affect running services
- **Back up configs** before modifying them (`cp nginx.conf nginx.conf.bak`)
- **Test configs** before reloading (`nginx -t` before `systemctl reload nginx`)
- **Sudo password** comes from `deploi-servers.json` — NOT from `.env`
- **No server deletion via API** — users must use kundepanel.deploi.no
- **curl is blocked** by the API — all API calls must use the Node.js helper pattern
- **clientid is a number** — wrong clientid returns "Not logged in" (messageId 41)
- **Duplicate server names** are allowed — always check `GetServers` before creating

## API Error Reference

| messageId | Message | Meaning |
|-----------|---------|---------|
| -1 | Email or Password Invalid | Wrong credentials |
| 4 | Password must be at least 8 characters... | Server password too weak |
| 8 | Memory must be more than 0... | RAM out of range (1-160 GB) |
| 9 | CPU must be more than 0... | CPU out of range (1-80) |
| 11 | OS is not one of the supported options | Invalid OS string |
| 13 | The API currently only supports creating one disk | Wrong disk count |
| 14 | Disk size must be between 5 and 10,000 GB | Disk size out of range |
| 23 | Request is not according to the API specifications | Missing required fields |
| 25 | Creating virtual server failed | Generic failure — check account or contact support |
| 41 | Not logged in | Token expired or invalid — re-authenticate |
| 80 | Server created | Success |
| 138 | Request blocked | Using curl — switch to Node.js |
