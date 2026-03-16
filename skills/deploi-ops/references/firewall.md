# Firewall — Two Layers

Deploi servers support two independent firewall layers. Understand both.

## Layer 1: UFW (on server via SSH)

Day-to-day port management. Use this always.

```bash
# Essential setup (do this on every new server)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22    # SSH — ALWAYS allow before enabling
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw enable

# Manage ports
sudo ufw allow 5432          # PostgreSQL
sudo ufw allow 3000          # Dev server
sudo ufw delete allow 3000   # Remove rule
sudo ufw status              # List rules
```

> **CRITICAL:** Always allow port 22 (SSH) before running `ufw enable`. Otherwise you will be locked out.

## Layer 2: Deploi Managed Firewall (via API)

Network-level firewall managed by Deploi infrastructure. Extra protection layer.

**List firewalls** (full payload):
```json
{ "command": "GetFirewalls", "token": "<t>", "clientid": "<id>" }
```

**Create firewall** (untested):
```json
{
  "command": "CreateFirewall",
  "token": "<t>",
  "clientid": "<id>",
  "name": "my-firewall",
  "serverid": "<server-id>"
}
```

**Add firewall rule** (untested):
```json
{
  "command": "AddFirewallRule",
  "token": "<t>",
  "firewallid": "<firewall-id>",
  "direction": "in",
  "protocol": "tcp",
  "port": "443",
  "action": "allow",
  "source": "0.0.0.0/0"
}
```

> **Untested commands.** `CreateFirewall` and `AddFirewallRule` payloads are from API docs.
> Verify at `api.deploi.no/api-docs` before use.

**Guidance:** Use UFW always — it's immediate and reliable. Add Deploi managed firewall for extra protection on production servers handling sensitive data.
