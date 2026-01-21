# Nagios Monitoring Setup (via Docker Compose)

This repository offers a streamlined approach to deploy **Nagios Core** using Docker Compose. It allows you to quickly set up a robust monitoring solution for various services, such as **FastAPI applications**, backend servers, network devices, and any other network-reachable hosts.

**Why this setup?**
*   **Simplicity**: Get Nagios up and running with minimal effort.
*   **Isolation**: Docker containers ensure a clean and isolated environment.
*   **Reproducibility**: Easily recreate your Nagios setup across different environments.
*   **Extensibility**: Simple integration for custom monitoring configurations.

---

## 🚀 Get Started

### Prerequisites

Before you begin, ensure you have the following installed on your system:

*   **Docker**: [Install Docker Engine](https://docs.docker.com/engine/install/)
*   **Docker Compose**: [Install Docker Compose](https://docs.docker.com/compose/install/)

---

## ⚡ Quick Setup (Recommended)

For the fastest way to get Nagios up and running with basic configurations:

### Run Setup Script

```bash
chmod +x setup_nagios.sh
./setup_nagios.sh
```

This script will automate the following:

*   **Docker Compose Setup**: Starts the Nagios container using `docker-compose.yml`.
*   **Admin Permissions**: Configures the `admin` user with necessary permissions for the Nagios web interface.
*   **Configuration Validation**: Restarts Nagios and validates its configuration to ensure everything is correct.
*   **Access Information**: Displays the URL for your Nagios dashboard.

You can access the Nagios Web UI at:

```
http://<your-server-ip>:8080/nagios
# or if running locally
http://localhost:8080/nagios
```

**Important Security Note**: The default credentials are:

```
Username: admin
Password: admin
```
**It is highly recommended to change these default credentials immediately for production environments.** You can modify them in the `docker-compose.yml` file under the `NAGIOSADMIN_USER` and `NAGIOSADMIN_PASS` environment variables.

---

### 🧹 To Completely Remove Nagios

To stop all Nagios-related Docker containers, remove images, and clean up associated volumes and networks, run the cleanup script:

```bash
chmod +x cleanup_nagios.sh
./cleanup_nagios.sh
```

This script performs a comprehensive cleanup, ensuring your system is ready for a fresh installation without leftover artifacts.

---

## 🧱 Manual Setup (Step-by-Step)

If you prefer a more granular control over the setup process, follow these manual steps:

### 1. Start Nagios using Docker Compose

This command will start the Nagios container in detached mode (`-d`), allowing it to run in the background.

```bash
docker-compose up -d
```

### 2. Wait for Initialization

Nagios needs a moment to initialize its services and configuration files. This `sleep` command pauses execution to ensure Nagios is ready before further commands are run.

```bash
sleep 15
```

### 3. Grant Admin Permissions

This command executes inside the running Nagios container to modify its CGI configuration, granting administrative privileges to the `admin` user for system information, configuration, and all services/hosts.

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

After modifying the configuration, restart the Nagios container to apply the changes.

```bash
docker-compose restart
```

### 5. Access the Web UI

Once Nagios has restarted, you can access its web interface using your server's IP address or `localhost`.

```
http://<your-server-ip>:8080/nagios
# or
http://localhost:8080/nagios
```

---

## 🧩 Add Custom Configurations

Nagios is highly customizable. You can add your own monitoring logic for specific services or hosts. Here's how to add a custom configuration for a FastAPI application as an example:

### 1. Create Your Custom Configuration File

Place your Nagios configuration file (e.g., `fastapi.cfg`) into the `nagios-config/` directory. This directory is mounted as a volume into the Nagios container at `/opt/nagios/etc/objects/custom/`.

Example `nagios-config/fastapi.cfg` content:

```nagios
define host {
    use                     linux-server
    host_name               fastapi-server
    alias                   FastAPI Backend
    address                 192.168.0.194
}

define service {
    use                     generic-service
    host_name               fastapi-server
    service_description     FastAPI Health Check
    check_command           check_http!-H 192.168.0.194 -p 8000 -u /health -e 200
    notifications_enabled   1
}

define service {
    use                     generic-service
    host_name               fastapi-server
    service_description     FastAPI Key Points API
    check_command           check_http!-H 192.168.0.194 -p 8000 -u /key-points-monitor -e 200
    notifications_enabled   1
}

define service {
    use                     generic-service
    host_name               fastapi-server
    service_description     FastAPI Explain API
    check_command           check_http!-H 192.168.0.194 -p 8000 -u /explain-monitor -e 200
    notifications_enabled   1
}
```

### 2. Register Your Custom Configuration with Nagios

You need to tell Nagios to include your new configuration file. This command appends a line to Nagios's main configuration file (`nagios.cfg`) to include `fastapi.cfg`.

```bash
docker exec nagios bash -c 'echo "cfg_file=/opt/nagios/etc/objects/custom/fastapi.cfg" >> /opt/nagios/etc/nagios.cfg'
```

### 3. Validate Nagios Configuration

It's crucial to validate your Nagios configuration after making changes to catch any syntax errors before restarting the service.

```bash
docker exec nagios /opt/nagios/bin/nagios -v /opt/nagios/etc/nagios.cfg
```

Look for `Total Errors: 0` in the output. If there are errors, correct them in your `.cfg` file and re-validate.

### 4. Restart Nagios

For the new configuration to take effect, you must restart the Nagios service.

```bash
docker-compose restart
```

---

## 📦 `docker-compose.yml`

This file defines the Nagios service using Docker Compose. It specifies the Docker image to use, port mappings, environment variables for Nagios administration, and volume mounts for custom configurations.

**Key configurable options:**

*   **`image: jasonrivers/nagios:latest`**: The Docker image used for Nagios. You can specify a different version if needed.
*   **`ports: - "8080:80"`**: Maps port `8080` on your host to port `80` inside the container. You can change `8080` to any available port on your host.
*   **`environment`**:
    *   `NAGIOSADMIN_USER`: The username for accessing the Nagios web interface. Defaults to `admin`.
    *   `NAGIOSADMIN_PASS`: The password for the Nagios admin user. Defaults to `admin`. **Remember to change this for security!**
*   **`volumes: - ./nagios-config:/opt/nagios/etc/objects/custom`**: Mounts your local `nagios-config` directory to `/opt/nagios/etc/objects/custom` inside the container, allowing you to easily add custom monitoring configurations.

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

## 💡 Tips & Troubleshooting

*   **Custom Configuration Files**: Always place your custom `.cfg` monitoring files in the `nagios-config/` directory. This ensures they are correctly mounted into the Nagios container.

    ```
    ./nagios-config/
    ```

*   **Validate Configuration**: After any changes to Nagios configuration files, it's crucial to validate them before restarting the service to catch syntax errors.

    ```bash
    docker exec nagios /opt/nagios/bin/nagios -v /opt/nagios/etc/nagios.cfg
    ```

*   **Restart Nagios**: For any configuration changes to take effect, remember to restart the Nagios container.

    ```bash
    docker-compose restart
    ```

*   **Monitor Container Logs**: If Nagios is not behaving as expected, check the container logs for detailed error messages.

    ```bash
    docker logs nagios
    ```

*   **Network Accessibility**: Ensure that any services or hosts you are monitoring (e.g., your FastAPI application) are accessible from within the Nagios container. This often means they should be on the same Docker network or correctly exposed.

---

## ✅ Verification

To verify that Nagios is running correctly:

1.  **Check Process Information**: Access the Nagios Web UI (e.g., `http://localhost:8080/nagios`). On the homepage, look for "Process Information." It should display "Running" along with the Nagios version (e.g., `Version 4.5.x`).

    If you see "Not Running," proceed to the next step.

2.  **Check Container Logs**: If Nagios is not running, examine the Docker container logs for diagnostic information:

    ```bash
    docker logs nagios
    ```
    This will provide insights into any startup failures or configuration issues.

---

## 👋 Contributing

We welcome contributions! If you have suggestions for improvements, new features, or bug fixes, please follow these steps:

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/your-feature-name`).
3.  Make your changes.
4.  Commit your changes (`git commit -m 'Add new feature'`).
5.  Push to the branch (`git push origin feature/your-feature-name`).
6.  Open a Pull Request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.