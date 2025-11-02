# Nagios Monitoring Setup (via Docker Compose)

This repository provides an easy way to set up **Nagios Core** using Docker Compose and configure it for monitoring services like **FastAPI**, **backend servers**, or any network host.

---

## ⚡ Quick Setup (Recommended)

If you want to get Nagios running instantly, just use the setup script:

### Run Setup Script

```bash
chmod +x setup_nagios.sh
./setup_nagios.sh
```

This script will:

* Start Nagios via Docker Compose
* Configure admin permissions
* Restart and validate the setup
* Show your Nagios dashboard URL

You can access Nagios at:

```
http://<your-server-ip>:8080/nagios
```

Example:

```
http://192.168.0.194:8080/nagios
```

Default credentials (can be changed in `docker-compose.yml`):

```
Username: admin
Password: admin
```

---

### 🧹 To Completely Remove Nagios

If you want to reset everything and start clean:

```bash
chmod +x clean_nagios.sh
./clean_nagios.sh
```

This script:

* Stops and removes all containers, images, and volumes
* Cleans up Docker networks and builders
* Leaves your system ready for a fresh installation

---

## 🧱 Manual Setup (Step-by-Step)

If you prefer to set up Nagios manually, follow these steps:

### 1. Start Nagios using Docker Compose

```bash
docker-compose up -d
```

### 2. Wait for Initialization

```bash
sleep 15
```

### 3. Grant Admin Permissions

```bash
docker exec nagios bash -c 'cat >> /opt/nagios/etc/cgi.cfg << "EOF"

# Admin user permissions
authorized_for_system_information=admin
authorized_for_configuration_information=admin
authorized_for_all_services=admin
authorized_for_all_hosts=admin
EOF'
```

### 4. Restart Nagios

```bash
docker-compose restart
```

### 5. Access the Web UI

```
http://<your-server-ip>:8080/nagios
```

---

## 🧩 Add Custom Configurations

If you have custom monitoring logic (for example, to check your FastAPI app):

1. Create a config file like `fastapi.cfg` in:

   ```
   nagios-config/fastapi.cfg
   ```

2. Register it with Nagios:

   ```bash
   docker exec nagios bash -c 'echo "cfg_file=/opt/nagios/etc/objects/custom/fastapi.cfg" >> /opt/nagios/etc/nagios.cfg'
   ```

3. Validate configuration:

   ```bash
   docker exec nagios /opt/nagios/bin/nagios -v /opt/nagios/etc/nagios.cfg
   ```

4. Restart Nagios:

   ```bash
   docker-compose restart
   ```

---

## 📦 `docker-compose.yml`

```yaml
version: '3.8'
services:
  nagios:
    image: jasonrivers/nagios:latest
    container_name: nagios
    ports:
      - "8080:80"
    environment:
      - NAGIOSADMIN_USER=admin
      - NAGIOSADMIN_PASS=admin
    volumes:
      - ./nagios-config:/opt/nagios/etc/objects/custom
    restart: unless-stopped
```

---

## 🧠 Notes

* Place all custom `.cfg` monitoring files in:

  ```
  ./nagios-config/
  ```
* Validate configuration anytime:

  ```bash
  docker exec nagios /opt/nagios/bin/nagios -v /opt/nagios/etc/nagios.cfg
  ```
* Restart Nagios after updates:

  ```bash
  docker-compose restart
  ```
* Ensure monitored services (like FastAPI) are accessible from within the container.

---

## ✅ Verification

If Nagios is running correctly, the homepage should show:

```
Version 4.5.x
Process Information: Running
```

If you see “Not Running,” check logs:

```bash
docker logs nagios
```


