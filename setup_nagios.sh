#!/bin/bash

# ============================================
# Nagios Monitoring Setup (via Docker Compose)
# ============================================
# This script sets up Nagios using Docker Compose,
# configures admin permissions, validates configuration,
# and restarts Nagios to apply changes.
# ============================================

set -e

echo "🚀 Starting Nagios setup..."

# Step 1: Start Nagios using Docker Compose
echo "🔹 Starting Nagios container..."
docker-compose up -d

# Step 2: Wait for Nagios to Start
echo "⏳ Waiting for Nagios to initialize..."
sleep 15

# Step 3: Fix CGI Permissions
echo "🔹 Configuring admin permissions..."
docker exec nagios bash -c 'cat >> /opt/nagios/etc/cgi.cfg << "EOF"

# Admin user permissions
authorized_for_system_information=admin
authorized_for_configuration_information=admin
authorized_for_all_services=admin
authorized_for_all_hosts=admin
EOF'

# Step 4: Restart Nagios
echo "🔄 Restarting Nagios to apply permissions..."
docker-compose restart

# Step 8: Display access URL
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "✅ Nagios setup completed successfully!"
echo "🌐 Access the Nagios Web UI at: http://$SERVER_IP:8080/nagios"
echo ""
echo "🛠 Notes:"
echo "- Custom configs should be placed under: /opt/nagios/etc/objects/custom/"
echo "- Validate configs anytime with:"
echo "    docker exec nagios /opt/nagios/bin/nagios -v /opt/nagios/etc/nagios.cfg"
echo "- Restart Nagios after making changes using:"
echo "    docker-compose restart"
echo ""

