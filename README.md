_This project has been created as part of the 42 curriculum by kclaudan._

---

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to broaden knowledge of system administration by using **Docker** to virtualize a small infrastructure composed of different services, all running inside a personal virtual machine.

Each service runs in its own dedicated Docker container, built from either Alpine Linux or Debian. The entire infrastructure is orchestrated using **Docker Compose** and brought up with a single `make` command.

### Services included

| Service                 | Role                                                    |
| ----------------------- | ------------------------------------------------------- |
| **NGINX**               | Reverse proxy with TLS (port 443 only, TLS 1.2/1.3)     |
| **WordPress + php-fpm** | CMS application server (no NGINX in this container)     |
| **MariaDB**             | Relational database for WordPress                       |
| **Volumes**             | Persistent storage for the database and WordPress files |
| **Docker Network**      | Private bridge network connecting all containers        |

> All containers are built from custom `Dockerfile`s — no pre-built images from Docker Hub are used (except the base Alpine/Debian images).

---

### Design choices

#### Virtual Machines vs Docker

|                  | Virtual Machine                        | Docker Container                                 |
| ---------------- | -------------------------------------- | ------------------------------------------------ |
| **Isolation**    | Full OS-level isolation via hypervisor | Process-level isolation via namespaces & cgroups |
| **Resource use** | Heavy — each VM runs a complete OS     | Lightweight — shares the host kernel             |
| **Startup time** | Minutes                                | Seconds                                          |
| **Portability**  | Large VM images (GBs)                  | Small layered images (MBs)                       |
| **Use case**     | Full OS separation, different kernels  | Microservices, reproducible environments         |

Docker is used in this project because each service (NGINX, WordPress, MariaDB) can be isolated, configured, and restarted independently, without the overhead of running a full OS per service.

---

#### Secrets vs Environment Variables

|                   | Docker Secrets                                              | Environment Variables                                        |
| ----------------- | ----------------------------------------------------------- | ------------------------------------------------------------ |
| **Storage**       | Stored in-memory (`tmpfs`), never written to disk or images | Stored in plain text in `docker-compose.yml` or `.env` files |
| **Exposure risk** | Not visible in `docker inspect`, not in image layers        | Visible in `docker inspect`, logs, and image history         |
| **Use case**      | Production credentials (passwords, keys)                    | Non-sensitive config (ports, hostnames)                      |
| **Availability**  | Only inside the container as a mounted file                 | Available as standard shell variables                        |

In this project, credentials (database passwords, WordPress admin password) are managed via a `.env` file that is **never committed to Git** (listed in `.gitignore`). In a production setting, Docker Secrets would be the preferred approach.

---

#### Docker Network vs Host Network

|               | Docker Network (bridge)                               | Host Network                                             |
| ------------- | ----------------------------------------------------- | -------------------------------------------------------- |
| **Isolation** | Containers communicate on an internal virtual network | Container shares the host's network stack directly       |
| **Security**  | Services not exposed unless explicitly published      | All ports on the container are exposed on the host       |
| **DNS**       | Containers resolve each other by service name         | No automatic DNS between containers                      |
| **Use case**  | Microservice architectures                            | Performance-critical workloads needing raw network speed |

This project uses a **custom bridge network** so that NGINX, WordPress, and MariaDB can communicate with each other by service name (e.g., `wordpress:9000`, `mariadb:3306`) without exposing those ports to the outside world. Only port 443 is published to the host via NGINX.

---

#### Docker Volumes vs Bind Mounts

|                 | Docker Volumes                                | Bind Mounts                                       |
| --------------- | --------------------------------------------- | ------------------------------------------------- |
| **Managed by**  | Docker (stored in `/var/lib/docker/volumes/`) | User (any path on the host filesystem)            |
| **Portability** | Fully portable across environments            | Tied to the host directory structure              |
| **Performance** | Optimised by Docker                           | Dependent on the host filesystem                  |
| **Use case**    | Persistent production data                    | Development — live code reload, local file access |
| **Backup**      | Via `docker volume` commands                  | Standard filesystem backup                        |

This project uses **named volumes** for both the MariaDB database and the WordPress files, mapped to `/home/<login>/data/` on the host machine (as required by the subject). This ensures data persists across container restarts.

---

## Instructions

### Prerequisites

- A Linux virtual machine (the project must run inside a VM)
- Docker and Docker Compose installed
- `make` available

### Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/<your_login>/inception.git
   cd inception
   ```

2. **Configure environment variables**

   Create a `.env` file at the root of the project (this file must never be committed):

   ```bash
   cp .env.example .env
   # Then edit .env with your values
   ```

   Required variables:

   ````env
   	DOMAIN_NAME=<your_login>.42.fr
   	SQL_ROOT_PASSWORD=<strong_password>
   	SQL_USER=<db_user>
   	SQL_PASSWORD=<db_password>
   	SQL_DATABASE=wordpress
   	WP_TITLE=<title>
   	WP_ADMIN=<admin_login>
   	WP_ADMIN_PASSWORD=<admin_password>
   	WP_ADMIN_EMAIL=<admin_email>   ```
   ````

3. **Add your domain to `/etc/hosts`** (on the VM)

   ```bash
   echo "127.0.0.1 <your_login>.42.fr" | sudo tee -a /etc/hosts
   ```

4. **Build and start all services**

   ```bash
   make
   ```

   This will:
   - Build all Docker images from their respective `Dockerfile`s
   - Create the Docker network and volumes
   - Start all containers via `docker compose up --build -d`

5. **Access the site**

   Open a browser and navigate to: `https://<your_login>.42.fr`

   > The TLS certificate is self-signed — accept the browser warning.

### Useful Makefile targets

| Command       | Description                             |
| ------------- | --------------------------------------- |
| `make`        | Build and start all containers          |
| `make down`   | Stop and remove containers              |
| `make clean`  | Stop containers and remove volumes      |
| `make fclean` | Full clean including images and volumes |
| `make re`     | Full rebuild from scratch               |

### Project structure

```
.
├── Makefile
├── .env                  ← not committed (contains credentials)
├── docker-compose.yml
└── srcs/
    ├── requirements/
    │   ├── nginx/
    │   │   ├── Dockerfile
    │   │   └── conf/
    │   ├── wordpress/
    │   │   ├── Dockerfile
    │   │   └── conf/
    │   └── mariadb/
    │       ├── Dockerfile
    │       └── conf/
    └── .env.example
```

---

## Resources

### Documentation

- [Docker official documentation](https://docs.docker.com/)
- [Docker Compose reference](https://docs.docker.com/compose/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB documentation](https://mariadb.com/kb/en/)
- [WordPress CLI documentation](https://developer.wordpress.org/cli/commands/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [OpenSSL — generating self-signed certificates](https://www.openssl.org/docs/man1.1.1/man1/openssl-req.html)
- [TLS 1.2 & 1.3 — RFC 8446](https://datatracker.ietf.org/doc/html/rfc8446)

### Articles & tutorials

- [Docker networking explained](https://docs.docker.com/network/)
- [Docker volumes vs bind mounts](https://docs.docker.com/storage/)
- [Docker secrets overview](https://docs.docker.com/engine/swarm/secrets/)
- [Understanding Docker bridge networks](https://docs.docker.com/network/bridge/)
- [WordPress installation with WP-CLI](https://make.wordpress.org/cli/handbook/guides/installing/)

### AI usage

AI (Claude by Anthropic) was used during this project for the following tasks:

- **Debugging** — Analysing error logs from Docker builds and container startup failures, and suggesting fixes.
- **NGINX configuration** — Generating and reviewing the TLS configuration block and `fastcgi_pass` directives for php-fpm.
- **WordPress automation** — Drafting the shell script used to configure WordPress via WP-CLI on first run.
- **Documentation** — Drafting and structuring this README, including the comparison tables.

All AI-generated suggestions were reviewed, tested, and adapted manually. No code was blindly copy-pasted without understanding (for real).
