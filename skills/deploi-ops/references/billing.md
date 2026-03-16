# Email, Billing & Other Services

## Email — OrderEmailService (untested)

```json
{
  "command": "OrderEmailService",
  "token": "<t>",
  "clientid": "<id>",
  "domain": "example.no",
  "type": "<type>"
}
```

Email types:
- `account` — standard email accounts (user@example.no)
- `transactional` — for app-sent emails (receipts, notifications)
- `m365` — Microsoft 365 integration

> **Untested.** Verify at `api.deploi.no/api-docs`. Creates a billable service — confirm with user first.

**Quick guidance:** Most vibe coders want `account` for business email or `transactional` for app email. M365 is for organizations already using Microsoft.

## Billing — GetInvoices

```json
{ "command": "GetInvoices", "token": "<t>", "clientid": "<id>" }
```

Display results as a clean table:
```
Invoice #  | Date       | Amount   | Status
-----------|------------|----------|--------
1234       | 2026-03-01 | 332 NOK  | Paid
1235       | 2026-03-15 | 131 NOK  | Pending
```

## User Info — GetUserInfo

```json
{ "command": "GetUserInfo", "token": "<t>", "clientid": "<id>" }
```

Returns account details: name, email, company, address.

## Other Services

- `GetWordpress` — list WordPress instances. Manage via kundepanel.deploi.no.
- `GetKubernetes` — list K8s clusters. Manage via kundepanel.deploi.no.
- `GetVPNs` — list VPN services. Manage via kundepanel.deploi.no.

All three use: `{ "command": "<Command>", "token": "<t>", "clientid": "<id>" }`
