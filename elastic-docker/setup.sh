#!/bin/bash

echo "🚀 Setting up Elasticsearch and Kibana..."

# Stop any existing containers
echo "📦 Stopping existing containers..."
docker compose down

# Start Elasticsearch first
echo "🔍 Starting Elasticsearch..."
docker compose up elasticsearch -d

# Wait for Elasticsearch to be ready
echo "⏳ Waiting for Elasticsearch to be ready..."
sleep 30

# Check if Elasticsearch is responding
echo "🔍 Checking Elasticsearch status..."
until curl -s http://localhost:9200/_cluster/health > /dev/null; do
    echo "⏳ Waiting for Elasticsearch to respond..."
    sleep 5
done

echo "✅ Elasticsearch is ready!"

# Create Kibana service account token
echo "🔑 Creating Kibana service account token..."
TOKEN_OUTPUT=$(docker exec elastic-docker-elasticsearch-1 /usr/share/elasticsearch/bin/elasticsearch-service-tokens create elastic/kibana kibana-token-setup 2>/dev/null)

if echo "$TOKEN_OUTPUT" | grep -q "SERVICE_TOKEN"; then
    # Extract the token value (everything after the = sign)
    TOKEN=$(echo "$TOKEN_OUTPUT" | grep "SERVICE_TOKEN" | sed 's/.*= //')
    echo "✅ Service token created successfully!"
    echo "🔑 Token: ${TOKEN:0:20}..."
    
    # Backup original kibana.yml
    cp docker/kibana.yml docker/kibana.yml.backup
    
    # Update kibana.yml to use service token
    cat > docker/kibana.yml << EOF
---
## Default Kibana configuration from Kibana base image.
## https://github.com/elastic/kibana/blob/master/src/dev/build/tasks/os_packages/docker_generator/templates/kibana_yml.template.js
#
server.name: kibana
server.host: "0.0.0.0"
elasticsearch.hosts: [ "http://elasticsearch:9200" ]
xpack.monitoring.ui.container.elasticsearch.enabled: true
elasticsearch.requestTimeout: 600000
## X-Pack security credentials
#
xpack.encryptedSavedObjects.encryptionKey: elasticelasticelasticelasticelasticelasticelasticelastic
elasticsearch.serviceAccountToken: $TOKEN
EOF
    
    echo "✅ Kibana configuration updated with service token"
else
    echo "❌ Failed to create service token. Please check Elasticsearch logs."
    echo "📋 Troubleshooting:"
    echo "   - Ensure Elasticsearch is running: docker compose ps"
    echo "   - Check Elasticsearch logs: docker compose logs elasticsearch"
    echo "   - Try restarting: docker compose restart elasticsearch"
    exit 1
fi

# Start Kibana
echo "📊 Starting Kibana..."
docker compose up kibana -d

# Wait for Kibana to be ready and check its status
echo "⏳ Waiting for Kibana to be ready..."
sleep 30

# Check if Kibana is responding
echo "🔍 Checking Kibana status..."
MAX_ATTEMPTS=12
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if curl -s -u elastic:elastic@123 http://localhost:5601/api/status > /dev/null 2>&1; then
        echo "✅ Kibana is ready!"
        break
    else
        ATTEMPT=$((ATTEMPT + 1))
        echo "⏳ Waiting for Kibana to respond... (attempt $ATTEMPT/$MAX_ATTEMPTS)"
        sleep 10
    fi
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "⚠️  Kibana is taking longer than expected to start. Check logs with: docker compose logs kibana"
fi

echo "🎉 Setup complete!"
echo ""
echo "🌐 Access your services:"
echo "   Elasticsearch: http://localhost:9200"
echo "   Kibana: http://localhost:5601"
echo ""
echo "🔐 Login credentials:"
echo "   Username: elastic"
echo "   Password: elastic@123"
echo ""
echo "📋 Useful commands:"
echo "   docker compose ps          - Check service status"
echo "   docker compose logs        - View all logs"
echo "   docker compose down        - Stop all services"
echo "   docker compose up -d       - Start all services" 
