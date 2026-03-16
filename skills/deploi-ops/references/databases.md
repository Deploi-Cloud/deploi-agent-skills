# Database Workflows

## Self-Managed on VPS (recommended for most users)

### PostgreSQL

```bash
sudo apt update && sudo apt install -y postgresql postgresql-contrib
sudo -u postgres createuser --pwprompt myappuser
sudo -u postgres createdb -O myappuser myappdb

# Connection string for your app:
# postgresql://myappuser:<password>@localhost:5432/myappdb
```

To allow remote access (from another Deploi server):
```bash
# Edit PostgreSQL config
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf
echo "host all all 0.0.0.0/0 md5" | sudo tee -a /etc/postgresql/*/main/pg_hba.conf
sudo systemctl restart postgresql
sudo ufw allow 5432
```

### MySQL

```bash
sudo apt update && sudo apt install -y mysql-server
sudo mysql -e "CREATE USER 'myappuser'@'localhost' IDENTIFIED BY '<password>';"
sudo mysql -e "CREATE DATABASE myappdb;"
sudo mysql -e "GRANT ALL ON myappdb.* TO 'myappuser'@'localhost';"

# Connection string:
# mysql://myappuser:<password>@localhost:3306/myappdb
```

## Deploi Managed Database

**List managed databases:**
```json
{ "command": "GetDatabases", "token": "<t>", "clientid": "<id>" }
```

Ordering managed databases may require kundepanel.deploi.no. Use the API to check what exists, but for provisioning new managed databases, use the customer portal.
