# Elasticsearch & Kibana Docker Setup

A simple Docker Compose setup for Elasticsearch and Kibana with automatic configuration.

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- At least 4GB of available RAM
- Ports 9200 and 5601 available

### One-Command Setup
```bash
chmod +x setup.sh
./setup.sh
```

### Manual Setup
1. **Start the services:**
   ```bash
   docker compose up -d
   ```

2. **Wait for services to be ready (2-3 minutes)**

3. **Access your services:**
   - Elasticsearch: http://localhost:9200
   - Kibana: http://localhost:5601

## 🔐 Authentication

**Default credentials:**
- Username: `elastic`
- Password: `elastic@123`

## 📋 Useful Commands

### Service Management
```bash
# Check service status
docker compose ps

# View logs
docker compose logs

# View specific service logs
docker compose logs elasticsearch
docker compose logs kibana

# Stop all services
docker compose down

# Start all services
docker compose up -d

# Restart services
docker compose restart
```

### Data Management
```bash
# Remove all data (WARNING: This will delete all data)
docker compose down -v

# Backup data
docker compose exec elasticsearch tar -czf /tmp/backup.tar.gz /usr/share/elasticsearch/data
docker cp elastic-docker-elasticsearch-1:/tmp/backup.tar.gz ./backup.tar.gz
```

## 🔧 Configuration Files

- `docker-compose.yml` - Main Docker Compose configuration
- `docker/elasticsearch.yml` - Elasticsearch configuration
- `docker/kibana.yml` - Kibana configuration

## 🐛 Troubleshooting

### Kibana won't start
If Kibana fails to start due to authentication issues:
1. Stop all services: `docker compose down`
2. Run the setup script: `./setup.sh`

### Elasticsearch health check fails
1. Check available memory: `free -h`
2. Ensure Docker has enough resources allocated
3. Restart Docker service if needed

### Port conflicts
If ports 9200 or 5601 are already in use:
1. Edit `docker-compose.yml`
2. Change the port mappings:
   ```yaml
   ports:
     - '9201:9200'  # Change 9200 to 9201
   ```

## 📊 System Requirements

- **RAM**: Minimum 4GB, Recommended 8GB+
- **CPU**: 2+ cores
- **Storage**: At least 10GB free space
- **Docker**: Version 20.10+

## 🔒 Security Notes

- This setup uses basic authentication
- For production use, consider:
  - Using HTTPS
  - Implementing proper SSL certificates
  - Setting up firewall rules
  - Using environment variables for passwords

## 📁 File Structure

```
elastic-docker/
├── docker-compose.yml
├── setup.sh
├── README.md
└── docker/
    ├── elasticsearch.yml
    └── kibana.yml
```

## 🆘 Support

If you encounter issues:
1. Check the logs: `docker compose logs`
2. Ensure Docker has enough resources
3. Try restarting the services: `docker compose restart`
4. For persistent issues, try: `docker compose down -v && ./setup.sh` 