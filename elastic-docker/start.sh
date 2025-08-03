#!/bin/bash

echo "🚀 Starting Elasticsearch and Kibana..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Start services
docker compose up -d

echo "⏳ Services are starting..."
echo "📊 Elasticsearch: http://localhost:9200"
echo "📈 Kibana: http://localhost:5601"
echo ""
echo "🔐 Login with: elastic / elastic@123"
echo ""
echo "📋 Commands:"
echo "   docker compose ps     - Check status"
echo "   docker compose logs   - View logs"
echo "   docker compose down   - Stop services" 