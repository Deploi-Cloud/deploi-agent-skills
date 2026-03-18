# Deploi API Call Helper

## Node.js API Helper Pattern

Use this pattern for ALL Deploi API calls:

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

Replace `<PAYLOAD>` with the JSON object for each command.

## Token Expiry Handling

If any API call returns `{"success":false,"message":"Not logged in","messageId":41}`, the token has expired. Re-authenticate by repeating the Login command before retrying the failed call.

## Authentication Response

**Success response:**
```json
{
  "success": true,
  "message": "",
  "messageId": -1,
  "data": {
    "nextstep": "none",
    "token": "uyskpvglnmgpigpahswgsigba",
    "clients": [{ "id": 928, "name": "Friendly Tech AS" }]
  }
}
```

## API Error Reference

| messageId | Message | Meaning |
|---------|---------|---------|
| 4 | Password must be at least 8 characters... | Server password too weak |
| 8 | Memory must be more than 0... | RAM out of range (1-160 GB) |
| 9 | CPU must be more than 0... | CPU out of range (1-80) |
| 11 | OS is not one of the supported options | Invalid OS string |
| 13 | The API currently only supports creating one disk | Wrong disk count |
| 14 | Disk size must be between 5 and 10 000 GB | Disk size out of range |
| 23 | Request is not according to the API specifications | Missing required fields |
| 25 | Creating virtual server failed | Generic creation failure — check account limits or contact Deploi support |
| 41 | Not logged in | Token expired or invalid — re-authenticate |
| 80 | Server created | Success |
| 127 | Email or Password Invalid | Wrong credentials |
| 138 | Request blocked | Using curl — switch to Node.js |

## Important Notes

- **SSH key is the primary access method.** Always use `allowRemotePasswordLogin: false` unless the user explicitly asks for password login.
- **Password is required by the API** even with SSH key — it becomes the server's sudo password. Always generate a unique password per server.
- **No server deletion via API.** To cancel/delete a server, the user must use kundepanel.deploi.no.
- **Duplicate names are allowed by the API** — always check with GetServers before creating.
- **Tokens are invalidated on Logout** and expire after inactivity — re-authenticate as needed.
- **Wrong clientid returns "Not logged in"** — if you get messageId 41, verify both token and clientid.
