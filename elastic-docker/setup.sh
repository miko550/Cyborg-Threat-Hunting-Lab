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
TOKEN=$(docker exec elastic-docker-elasticsearch-1 /usr/share/elasticsearch/bin/elasticsearch-service-tokens create elastic/kibana kibana-token | grep "SERVICE_TOKEN" | awk '{print $3}')

if [ -z "$TOKEN" ]; then
    echo "❌ Failed to create service token. Using basic authentication instead."
    # Update kibana.yml to use basic auth
    sed -i 's/elasticsearch.serviceAccountToken:.*/elasticsearch.username: elastic\nelasticsearch.password: elastic@123/' docker/kibana.yml
else
    echo "✅ Service token created successfully!"
    # Update kibana.yml to use service token
    sed -i "s/elasticsearch.username: elastic/elasticsearch.serviceAccountToken: $TOKEN/" docker/kibana.yml
    sed -i '/elasticsearch.password: elastic@123/d' docker/kibana.yml
fi

# Start Kibana
echo "📊 Starting Kibana..."
docker compose up kibana -d

# Wait for Kibana to be ready
echo "⏳ Waiting for Kibana to be ready..."
sleep 30

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