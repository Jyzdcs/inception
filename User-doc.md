# User Documentation — Inception

This document is intended for **end users and administrators** who want to run, access, and maintain the Inception stack. No Docker expertise is required.

---

## What services does this stack provide?

The Inception stack runs three services, each in its own isolated container:

| Service       | What it does                                        | Accessible from outside? |
| ------------- | --------------------------------------------------- | ------------------------ |
| **NGINX**     | Serves the website over HTTPS and acts as a gateway | ✅ Yes — port 443        |
| **WordPress** | Hosts and renders the website content (CMS)         | ❌ No — internal only    |
| **MariaDB**   | Stores all website data (posts, users, settings)    | ❌ No — internal only    |

All traffic enters through NGINX only. WordPress and MariaDB are never directly reachable from outside the stack — this is intentional for security.

---

## Starting and stopping the project

Open a terminal inside the virtual machine and navigate to the project directory.

### Start everything

```bash
make
```

This builds the images if needed and starts all three containers in the background. The first run may take a minute or two as images are built.

### Stop everything (keep your data)

```bash
make down
```

Containers are stopped and removed, but your database and WordPress files are preserved on disk. Running `make` again will restart everything with your data intact.

### Stop everything and wipe all data

```bash
make fclean
```

> ⚠️ This deletes all volumes, meaning **all WordPress content and database records will be lost**. Only use this if you want a completely fresh start.

### Check that everything started correctly

```bash
docker compose -f docker-compose.yml ps
```

All three services (`nginx`, `wordpress`, `mariadb`) should show a status of `Up`.

---

## Accessing the website

### Public website

Open a browser and go to:

```
https://<your_login>.42.fr
```

Replace `<your_login>` with the actual login configured in the project.

> The site uses a **self-signed TLS certificate**. Your browser will display a security warning — this is expected. Click "Advanced" and proceed to the site.

### WordPress administration panel

```
https://<your_login>.42.fr/wp-admin
```

Log in with the **WordPress admin credentials** (see the section below on credentials).

---

## Locating and managing credentials

All credentials are stored in a single file at the root of the project:

```
.env
```

> This file is **not tracked by Git** and must never be shared or committed. It contains passwords in plain text.

Open it with any text editor:

```bash
nano .env
# or
cat .env
```

### What credentials are stored there?

| Variable                              | What it is                               |
| ------------------------------------- | ---------------------------------------- |
| `MYSQL_ROOT_PASSWORD`                 | MariaDB root password                    |
| `MYSQL_USER` / `MYSQL_PASSWORD`       | WordPress database user credentials      |
| `WP_ADMIN_USER` / `WP_ADMIN_PASSWORD` | WordPress admin login                    |
| `WP_USER` / `WP_USER_PASSWORD`        | A second, lower-privilege WordPress user |

### Changing a password

1. Edit `.env` with the new value.
2. Run `make fclean` to wipe existing data (required — passwords are baked into the database on first run).
3. Run `make` to rebuild everything fresh with the new credentials.

---

## Checking that services are running correctly

### Quick status check

```bash
docker compose -f docker-compose.yml ps
```

All services should show `Up`. If any shows `Exit` or `Restarting`, check the logs.

### View logs for all services

```bash
make logs
```

### View logs for a specific service

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Test the website is reachable

```bash
curl -k https://<your_login>.42.fr
```

You should see HTML output. The `-k` flag bypasses the self-signed certificate warning.

### Check the database is responding

```bash
docker exec -it mariadb mariadb -u root -p
# Enter MYSQL_ROOT_PASSWORD when prompted
```

Once connected, you can run:

```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
```

Type `exit` to disconnect.

---

## Troubleshooting

| Symptom                            | Likely cause                               | What to try                                                      |
| ---------------------------------- | ------------------------------------------ | ---------------------------------------------------------------- |
| Browser shows "connection refused" | Containers not running                     | Run `docker compose ps` and check status                         |
| Browser shows "502 Bad Gateway"    | WordPress container not ready              | Wait 10–15 seconds and refresh, or check `docker logs wordpress` |
| WordPress shows database error     | MariaDB not yet ready or wrong credentials | Check `docker logs mariadb` and verify `.env` values             |
| Site shows default NGINX page      | NGINX misconfiguration                     | Check `docker logs nginx`                                        |
| `make` fails immediately           | Docker daemon not running                  | Run `sudo service docker start` or equivalent                    |
