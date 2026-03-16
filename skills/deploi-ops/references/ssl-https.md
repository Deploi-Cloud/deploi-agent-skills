# SSL/HTTPS Recipe

The #1 pain point for vibe coders. This section is standalone so AI agents can find it fast.

## Prerequisites

- Domain A record pointing to the server IP (verify: `dig <domain>` should return server IP)
- Ports 80 and 443 open on the server (`sudo ufw allow 80 && sudo ufw allow 443`)
- App running on a local port (e.g., 3000)

## Install Certbot & Get Certificate

```bash
# On the server via SSH
sudo apt update && sudo apt install -y certbot python3-certbot-nginx nginx
sudo certbot --nginx -d example.no -d www.example.no --non-interactive --agree-tos -m user@example.com
```

This automatically configures Nginx with HTTPS. If you need manual control, use the template below.

## Full Nginx HTTPS Reverse Proxy Template

For apps running on a local port (e.g., Node.js on port 3000):

```nginx
server {
    listen 80;
    server_name example.no www.example.no;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name example.no www.example.no;

    ssl_certificate /etc/letsencrypt/live/example.no/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.no/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Save to `/etc/nginx/sites-available/<app-name>`, then:
```bash
sudo ln -s /etc/nginx/sites-available/<app-name> /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx
```

## Auto-Renewal Verification

Certbot installs a systemd timer automatically. Verify:
```bash
sudo certbot renew --dry-run
```

## Troubleshooting

- **"DNS not propagated yet"** — `dig <domain>` doesn't return server IP. Wait and retry (usually minutes for Deploi-managed DNS).
- **"Connection refused on port 80"** — Nginx not running or UFW blocking. Check `sudo systemctl status nginx` and `sudo ufw status`.
- **"Challenge failed"** — Certbot can't reach port 80. Ensure no other service is bound to port 80 and the firewall allows it.
