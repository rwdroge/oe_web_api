#!/bin/bash
##########################################################################
# deploy-production.sh
# Production deployment script for GenericService application
# 
# Usage: ./deploy-production.sh [options]
# Options:
#   --db-host <hostname>     Database server hostname
#   --pas1-path <path>       Path to PASOE instance 1
#   --pas2-path <path>       Path to PASOE instance 2
#   --skip-compile           Skip compilation step
#   --skip-db                Skip database setup
#   --skip-otel              Skip OpenTelemetry stack setup
##########################################################################

set -e  # Exit on error

# Default values
DB_HOST="localhost"
PAS1_PATH="/opt/oe_web_api/pas1"
PAS2_PATH="/opt/oe_web_api/pas2"
SKIP_COMPILE=false
SKIP_DB=false
SKIP_OTEL=false
APP_ROOT="/opt/oe_web_api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --db-host)
            DB_HOST="$2"
            shift 2
            ;;
        --pas1-path)
            PAS1_PATH="$2"
            shift 2
            ;;
        --pas2-path)
            PAS2_PATH="$2"
            shift 2
            ;;
        --skip-compile)
            SKIP_COMPILE=true
            shift
            ;;
        --skip-db)
            SKIP_DB=true
            shift
            ;;
        --skip-otel)
            SKIP_OTEL=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Production Deployment Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo "Database Host: $DB_HOST"
echo "PASOE Instance 1: $PAS1_PATH"
echo "PASOE Instance 2: $PAS2_PATH"
echo -e "${GREEN}========================================${NC}"
echo

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command_exists proserve; then
    echo -e "${RED}✗ OpenEdge not found in PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✓ OpenEdge found${NC}"

# Step 1: Database Setup
if [ "$SKIP_DB" = false ]; then
    echo
    echo -e "${YELLOW}Step 1: Setting up database...${NC}"
    
    cd "$APP_ROOT/db"
    
    # Check if database exists
    if [ ! -f "sports2020.db" ]; then
        echo "Creating Sports2020 database..."
        prodb sports2020 $DLC/sports2020
        echo -e "${GREEN}✓ Database created${NC}"
    else
        echo -e "${GREEN}✓ Database already exists${NC}"
    fi
    
    # Start database if not running
    if ! proshut sports2020 -C list 2>/dev/null | grep -q "sports2020"; then
        echo "Starting database..."
        bash "$APP_ROOT/scripts/start_db.sh"
        sleep 5
        echo -e "${GREEN}✓ Database started${NC}"
    else
        echo -e "${GREEN}✓ Database already running${NC}"
    fi
else
    echo -e "${YELLOW}Skipping database setup${NC}"
fi

# Step 2: Compile Application
if [ "$SKIP_COMPILE" = false ]; then
    echo
    echo -e "${YELLOW}Step 2: Compiling application code...${NC}"
    
    cd "$APP_ROOT"
    
    # Update as.pf with correct database host
    sed -i "s/-H .*/-H $DB_HOST/" conf/as.pf
    
    # Compile
    $DLC/bin/_progres -b -p scripts/compile_all.p \
        -db sports2020 -H $DB_HOST -S 10000 -1 \
        > logs/compile.log 2>&1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Compilation successful${NC}"
    else
        echo -e "${RED}✗ Compilation failed. Check logs/compile.log${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}Skipping compilation${NC}"
fi

# Step 3: Deploy to PASOE Instance 1
echo
echo -e "${YELLOW}Step 3: Deploying to PASOE Instance 1...${NC}"

# Stop instance 1
if [ -d "$PAS1_PATH" ]; then
    echo "Stopping PASOE Instance 1..."
    cd "$PAS1_PATH/bin"
    ./tcman stop 2>/dev/null || true
    sleep 3
fi

# Create instance if it doesn't exist
if [ ! -d "$PAS1_PATH" ]; then
    echo "Creating PASOE Instance 1..."
    cd $DLC/bin
    ./tcman create -p 8810 -P 8811 "$PAS1_PATH"
fi

# Deploy configuration
echo "Deploying configuration..."
cp "$APP_ROOT/conf/openedge-pas1.properties" "$PAS1_PATH/conf/openedge.properties"
cp "$APP_ROOT/conf/as.pf" "$PAS1_PATH/conf/"
cp "$APP_ROOT/conf/memProfConf" "$PAS1_PATH/openedge/" 2>/dev/null || true

# Deploy OpenTelemetry configuration
echo "Deploying OpenTelemetry configuration..."
cp "$APP_ROOT/conf/otelconfig.json" "$PAS1_PATH/conf/"

# Deploy application code
echo "Deploying application code..."
mkdir -p "$PAS1_PATH/openedge"
cp -r "$APP_ROOT/src"/* "$PAS1_PATH/openedge/"
cp -r "$APP_ROOT/lib"/* "$PAS1_PATH/openedge/" 2>/dev/null || true

# Deploy WebHandlers
echo "Deploying WebHandlers..."
mkdir -p "$PAS1_PATH/webapps/ROOT/WEB-INF"
cp "$APP_ROOT/src/webhandlers/ROOT.handlers" "$PAS1_PATH/webapps/ROOT/WEB-INF/"

# Start instance 1
echo "Starting PASOE Instance 1..."
cd "$PAS1_PATH/bin"
./tcman start

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ PASOE Instance 1 deployed and started${NC}"
else
    echo -e "${RED}✗ Failed to start PASOE Instance 1${NC}"
    exit 1
fi

# Step 4: Deploy to PASOE Instance 2
echo
echo -e "${YELLOW}Step 4: Deploying to PASOE Instance 2...${NC}"

# Stop instance 2
if [ -d "$PAS2_PATH" ]; then
    echo "Stopping PASOE Instance 2..."
    cd "$PAS2_PATH/bin"
    ./tcman stop 2>/dev/null || true
    sleep 3
fi

# Create instance if it doesn't exist
if [ ! -d "$PAS2_PATH" ]; then
    echo "Creating PASOE Instance 2..."
    cd $DLC/bin
    ./tcman create -p 8820 -P 8821 "$PAS2_PATH"
fi

# Deploy configuration
echo "Deploying configuration..."
cp "$APP_ROOT/conf/openedge-pas2.properties" "$PAS2_PATH/conf/openedge.properties"
cp "$APP_ROOT/conf/as.pf" "$PAS2_PATH/conf/"
cp "$APP_ROOT/conf/memProfConf" "$PAS2_PATH/openedge/" 2>/dev/null || true

# Deploy OpenTelemetry configuration
echo "Deploying OpenTelemetry configuration..."
cp "$APP_ROOT/conf/otelconfig-pas2.json" "$PAS2_PATH/conf/otelconfig.json"

# Deploy application code
echo "Deploying application code..."
mkdir -p "$PAS2_PATH/openedge"
cp -r "$APP_ROOT/src"/* "$PAS2_PATH/openedge/"
cp -r "$APP_ROOT/lib"/* "$PAS2_PATH/openedge/" 2>/dev/null || true

# Deploy WebHandlers
echo "Deploying WebHandlers..."
mkdir -p "$PAS2_PATH/webapps/ROOT/WEB-INF"
cp "$APP_ROOT/src/webhandlers/ROOT.handlers" "$PAS2_PATH/webapps/ROOT/WEB-INF/"

# Start instance 2
echo "Starting PASOE Instance 2..."
cd "$PAS2_PATH/bin"
./tcman start

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ PASOE Instance 2 deployed and started${NC}"
else
    echo -e "${RED}✗ Failed to start PASOE Instance 2${NC}"
    exit 1
fi

# Step 5: Setup OpenTelemetry (Optional)
if [ "$SKIP_OTEL" = false ]; then
    echo
    echo -e "${YELLOW}Step 5: Setting up OpenTelemetry observability...${NC}"
    
    # Check if Docker is available
    if command_exists docker; then
        echo "Starting OpenTelemetry stack..."
        cd "$APP_ROOT"
        
        # Check if docker-compose or docker compose is available
        if command_exists docker-compose; then
            docker-compose -f docker-compose-observability.yaml up -d
        elif docker compose version >/dev/null 2>&1; then
            docker compose -f docker-compose-observability.yaml up -d
        else
            echo -e "${YELLOW}⚠ Docker Compose not found, skipping OpenTelemetry stack${NC}"
        fi
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ OpenTelemetry Collector started${NC}"
            echo "  - Collector endpoint: http://localhost:4317 (gRPC)"
            echo "  - Collector endpoint: http://localhost:4318 (HTTP)"
            echo "  - Health check: http://localhost:13133"
            echo "  - Exporting to: /var/log/otel/*.jsonl"
        else
            echo -e "${YELLOW}⚠ Failed to start OpenTelemetry Collector${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Docker not found, skipping OpenTelemetry stack${NC}"
        echo "  To enable observability, install Docker and run:"
        echo "  ./scripts/start-observability.sh"
    fi
else
    echo -e "${YELLOW}Skipping OpenTelemetry setup${NC}"
fi

# Step 6: Verify Deployment
echo
echo -e "${YELLOW}Step 6: Verifying deployment...${NC}"

sleep 10  # Wait for instances to fully start

# Check instance 1
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8810/web/api/meta/customers | grep -q "200"; then
    echo -e "${GREEN}✓ PASOE Instance 1 responding${NC}"
else
    echo -e "${RED}✗ PASOE Instance 1 not responding${NC}"
fi

# Check instance 2
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8820/web/api/meta/customers | grep -q "200"; then
    echo -e "${GREEN}✓ PASOE Instance 2 responding${NC}"
else
    echo -e "${RED}✗ PASOE Instance 2 not responding${NC}"
fi

# Final Summary
echo
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Summary${NC}"
echo -e "${GREEN}========================================${NC}"
echo "Database: Running on port 10000"
echo "PASOE Instance 1: http://localhost:8810"
echo "PASOE Instance 2: http://localhost:8820"
echo
echo "API Endpoints:"
echo "  - WEB Transport: http://localhost:8810/web/api/data/customers"
echo "  - APSV Transport: http://localhost:8810/pas/apsv"
echo
echo -e "${GREEN}✓✓✓ Deployment completed successfully! ✓✓✓${NC}"
echo
echo "OpenTelemetry Configuration:"
if [ "$SKIP_OTEL" = false ] && command_exists docker; then
    echo "  - Collector: http://localhost:4317 (gRPC), http://localhost:4318 (HTTP)"
    echo "  - Health check: http://localhost:13133"
    echo "  - Exporting to: /var/log/otel/traces.jsonl"
    echo "  - Exporting to: /var/log/otel/metrics.jsonl"
    echo "  - Exporting to: /var/log/otel/logs.jsonl"
else
    echo "  - Config files deployed to PASOE instances"
    echo "  - To start collector: ./scripts/start-observability.sh"
fi
echo
echo "Next steps:"
echo "1. Run APSV transport tests: _progres -p test/run-all-apsv-tests.p"
echo "2. Generate traffic: curl http://localhost:8810/web/api/data/customers"
echo "3. Check OTLP files: tail -f /var/log/otel/traces.jsonl"
echo "4. Start your MongoDB persistence service"
echo "5. Configure load balancer (if applicable)"
echo "6. Review logs in pas1/logs and pas2/logs"
