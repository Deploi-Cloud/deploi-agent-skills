# Domain & DNS Management

## Full Payloads (tested/low-risk)

**Check domain availability** (no auth):
```json
{ "command": "DomainAvailable", "domain": "example.no" }
```

**Get domain pricing** (no auth):
```json
{ "command": "GetDomainPrice", "domain": "example.no" }
```

**List your domains:**
```json
{ "command": "GetDomains", "token": "<t>", "clientid": "<id>" }
```

**List DNS records for a domain:**
```json
{ "command": "GetDomainRecords", "token": "<t>", "domainname": "example.no" }
```

**Add a DNS record:**
```json
{
  "command": "AddDomainRecord",
  "token": "<t>",
  "domainname": "example.no",
  "type": "A",
  "host": "@",
  "value": "193.69.50.148",
  "ttl": 3600
}
```

Supported record types: `A`, `AAAA`, `CNAME`, `MX`, `TXT`, `SRV`

**Delete a DNS record:**
```json
{ "command": "DeleteDomainRecord", "token": "<t>", "domainname": "example.no", "id": "<record-id>" }
```

Get the `id` from `GetDomainRecords` first.

## DNS Recipes

**Point domain to server (most common):**
- A record: `@` → `<server-ip>` (root domain)
- A record: `www` → `<server-ip>` (www subdomain)

**Subdomain for API:**
- A record: `api` → `<server-ip>`

**Email (MX records):**
- MX record: `@` → `mail.provider.com` with priority (depends on email provider)

**SPF for email sending:**
- TXT record: `@` → `v=spf1 include:_spf.provider.com ~all`

## OrderDomain (untested)

Register or transfer a domain. Verify payload format at `api.deploi.no/api-docs` before use.

**Expected params:**
```json
{
  "command": "OrderDomain",
  "token": "<t>",
  "clientid": "<id>",
  "domain": "example.no",
  "years": 1,
  "owner": {
    "firstname": "<first name>",
    "lastname": "<last name>",
    "email": "<email>",
    "phone": "<+47xxxxxxxx>",
    "address": "<street address>",
    "city": "<city>",
    "zip": "<postal code>",
    "country": "NO",
    "type": "person"
  }
}
```

> **Untested command.** The payload above is based on API docs, not live testing.
> Norwegian defaults: `country: "NO"`, `type: "person"`. For businesses, `type` may be `"organization"`.
> Domain registration creates a billable resource — confirm with the user before ordering.
