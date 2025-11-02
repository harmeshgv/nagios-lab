#!/bin/bash
echo "🧹 COMPLETELY Removing Nagios Setup..."

echo "1. Stopping containers..."
docker stop $(docker ps -aq) 2>/dev/null

echo "2. Removing containers..."
docker rm $(docker ps -aq) 2>/dev/null

echo "3. Removing Docker Compose..."
docker-compose down --rmi all --volumes --remove-orphans 2>/dev/null

echo "4. Removing images..."
docker rmi -f $(docker images -q) 2>/dev/null

echo "5. Removing volumes..."
docker volume rm $(docker volume ls -q) 2>/dev/null

echo "6. Cleaning system..."
docker system prune -a -f --volumes
docker network prune -f
docker builder prune -a -f

echo "✅ COMPLETELY CLEANED!"
echo ""
echo "Final check:"
echo "Containers: $(docker ps -a | wc -l)"
echo "Images: $(docker images | wc -l)"
echo "Volumes: $(docker volume ls | wc -l)"