# Automatic Infrastructure Creation

## Overview
The deployment script (`scripts/deploy-production.sh`) now automatically creates the database and PASOE instances if they don't already exist. This simplifies initial deployment and ensures consistent infrastructure setup.

## What Gets Created Automatically

### 1. Database Creation
**Location**: `/opt/oe_web_api/db/sports2020.db`

**Creation Method**:
- Uses `prodb` command to create database from Sports2020 template
- Falls back to `procopy` if `prodb` is not available
- Creates database directory structure automatically

**Command Used**:
```bash
prodb sports2020 Sports2020
# or fallback:
procopy "$DLC/sports2020" sports2020
```

**When**:
- Only creates if `sports2020.db` doesn't exist
- Can be skipped with `--skip-db` flag

### 2. PASOE Instance 1 Creation
**Location**: `/opt/oe_web_api/pas1`

**Creation Method**:
- Uses `tcman.sh` (or `tcman`) to create new PASOE instance
- Configures HTTP port 8810 and HTTPS port 8811
- Creates parent directories automatically

**Command Used**:
```bash
$DLC/bin/tcman.sh create -p 8810 -P 8811 /opt/oe_web_api/pas1
```

**When**:
- Only creates if instance directory doesn't exist
- Always checks and creates if missing

### 3. PASOE Instance 2 Creation
**Location**: `/opt/oe_web_api/pas2`

**Creation Method**:
- Uses `tcman.sh` (or `tcman`) to create new PASOE instance
- Configures HTTP port 8820 and HTTPS port 8821
- Creates parent directories automatically

**Command Used**:
```bash
$DLC/bin/tcman.sh create -p 8820 -P 8821 /opt/oe_web_api/pas2
```

**When**:
- Only creates if instance directory doesn't exist
- Always checks and creates if missing

## Deployment Flow

### First-Time Deployment
```
1. Check prerequisites (OpenEdge in PATH)
2. Create database directory → Create database from template
3. Compile application code
4. Create PASOE Instance 1 → Deploy config → Deploy code → Start
5. Create PASOE Instance 2 → Deploy config → Deploy code → Start
6. Setup OpenTelemetry Collector (optional)
```

### Subsequent Deployments
```
1. Check prerequisites
2. Database already exists → Skip creation
3. Compile application code
4. PASOE Instance 1 exists → Stop → Deploy → Start
5. PASOE Instance 2 exists → Stop → Deploy → Start
6. OpenTelemetry Collector (optional)
```

## Usage Examples

### Complete Fresh Deployment
```bash
# Creates everything from scratch
./scripts/deploy-production.sh
```

### Custom Paths
```bash
# Create instances in custom locations
./scripts/deploy-production.sh \
  --pas1-path /custom/path/pas1 \
  --pas2-path /custom/path/pas2
```

### Skip Database Creation
```bash
# Use existing database, create PASOE instances
./scripts/deploy-production.sh --skip-db
```

### Skip OpenTelemetry
```bash
# Create infrastructure without OTel
./scripts/deploy-production.sh --skip-otel
```

## Prerequisites

### Required
- OpenEdge installation with `$DLC` environment variable set
- `proserve` command in PATH
- `tcman.sh` or `tcman` in `$DLC/bin`
- Write permissions to deployment directories

### Optional
- Docker (for OpenTelemetry Collector)
- `prodb` command (falls back to `procopy`)

## Error Handling

### Database Creation Failures
**Symptom**: "Failed to create database"

**Possible Causes**:
- Insufficient disk space
- No write permissions to `/opt/oe_web_api/db`
- Sports2020 template not found in `$DLC`

**Solution**:
```bash
# Check disk space
df -h /opt/oe_web_api

# Check permissions
ls -la /opt/oe_web_api

# Verify Sports2020 template
ls -la $DLC/sports2020*
```

### PASOE Instance Creation Failures
**Symptom**: "Failed to create PASOE Instance"

**Possible Causes**:
- `tcman` not found in `$DLC/bin`
- Ports 8810/8811 or 8820/8821 already in use
- Insufficient permissions
- Invalid instance path

**Solution**:
```bash
# Check tcman exists
ls -la $DLC/bin/tcman*

# Check ports available
netstat -an | grep -E '8810|8811|8820|8821'

# Check permissions
ls -la /opt/oe_web_api

# Manually create instance
$DLC/bin/tcman.sh create -p 8810 -P 8811 /opt/oe_web_api/pas1
```

## Manual Creation (Alternative)

If automatic creation fails, you can create infrastructure manually:

### Manual Database Creation
```bash
# Navigate to database directory
cd /opt/oe_web_api/db

# Create database from Sports2020 template
prodb sports2020 Sports2020

# Or use procopy
procopy $DLC/sports2020 sports2020

# Verify creation
ls -la sports2020.*
```

### Manual PASOE Instance Creation
```bash
# Create Instance 1
$DLC/bin/tcman.sh create -p 8810 -P 8811 /opt/oe_web_api/pas1

# Create Instance 2
$DLC/bin/tcman.sh create -p 8820 -P 8821 /opt/oe_web_api/pas2

# Verify creation
ls -la /opt/oe_web_api/pas1
ls -la /opt/oe_web_api/pas2
```

## Verification

### Check Database
```bash
# Check database files exist
ls -la /opt/oe_web_api/db/sports2020.*

# Check database can be connected
proserve sports2020 -S 10000 -H localhost
proshut sports2020 -by
```

### Check PASOE Instances
```bash
# Check instance directories
ls -la /opt/oe_web_api/pas1
ls -la /opt/oe_web_api/pas2

# Check instance status
/opt/oe_web_api/pas1/bin/tcman status
/opt/oe_web_api/pas2/bin/tcman status

# Check ports
netstat -an | grep -E '8810|8811|8820|8821'
```

## Directory Structure Created

```
/opt/oe_web_api/
├── db/
│   ├── sports2020.db          # Database file
│   ├── sports2020.lg          # Log file
│   ├── sports2020.b1          # Data extent
│   └── sports2020.d1          # Additional extents
├── pas1/                      # PASOE Instance 1
│   ├── bin/
│   │   ├── tcman              # Instance control script
│   │   └── ...
│   ├── conf/
│   │   ├── openedge.properties
│   │   ├── as.pf
│   │   └── otelconfig.json
│   ├── openedge/              # Application code
│   │   └── src/
│   ├── webapps/
│   │   └── ROOT/
│   └── logs/
└── pas2/                      # PASOE Instance 2
    ├── bin/
    ├── conf/
    ├── openedge/
    ├── webapps/
    └── logs/
```

## Configuration Files Required

The following configuration files must exist before running deployment:

### For Database
- `conf/as.pf` - Database connection parameters

### For PASOE Instance 1
- `conf/openedge-pas1.properties` - Instance configuration
- `conf/as.pf` - Database connection
- `conf/otelconfig.json` - OpenTelemetry config
- `conf/memProfConf` - Memory profiling (optional)

### For PASOE Instance 2
- `conf/openedge-pas2.properties` - Instance configuration
- `conf/as.pf` - Database connection
- `conf/otelconfig-pas2.json` - OpenTelemetry config
- `conf/memProfConf` - Memory profiling (optional)

## Best Practices

### 1. First-Time Setup
```bash
# Run with all defaults for initial setup
./scripts/deploy-production.sh

# Verify everything is running
./scripts/deploy-production.sh --skip-compile --skip-db --skip-otel
```

### 2. Development Workflow
```bash
# Make code changes
# ...

# Redeploy without recreating infrastructure
./scripts/deploy-production.sh
```

### 3. Clean Slate
```bash
# Remove everything
rm -rf /opt/oe_web_api/db/sports2020.*
rm -rf /opt/oe_web_api/pas1
rm -rf /opt/oe_web_api/pas2

# Recreate from scratch
./scripts/deploy-production.sh
```

### 4. Backup Before Deployment
```bash
# Backup database
cp /opt/oe_web_api/db/sports2020.db /backup/sports2020.db.$(date +%Y%m%d)

# Backup instance configs
tar -czf /backup/pas-config-$(date +%Y%m%d).tar.gz \
  /opt/oe_web_api/pas1/conf \
  /opt/oe_web_api/pas2/conf
```

## Troubleshooting

### "tcman not found"
```bash
# Check OpenEdge installation
echo $DLC
ls -la $DLC/bin/tcman*

# Add to PATH if needed
export PATH=$DLC/bin:$PATH
```

### "Database already exists" but corrupted
```bash
# Remove corrupted database
rm -f /opt/oe_web_api/db/sports2020.*

# Redeploy
./scripts/deploy-production.sh
```

### "Port already in use"
```bash
# Find what's using the port
lsof -i :8810
lsof -i :8820

# Kill the process or use different ports
./scripts/deploy-production.sh \
  --pas1-path /opt/oe_web_api/pas1_alt \
  --pas2-path /opt/oe_web_api/pas2_alt
```

## Summary

✅ **Automatic Creation**:
- Database from Sports2020 template
- PASOE Instance 1 (ports 8810/8811)
- PASOE Instance 2 (ports 8820/8821)
- All necessary directories

✅ **Smart Detection**:
- Only creates if doesn't exist
- Skips creation on subsequent runs
- Validates before proceeding

✅ **Error Handling**:
- Clear error messages
- Exits on failure
- Provides troubleshooting hints

✅ **Flexibility**:
- Custom paths supported
- Skip options available
- Manual creation possible
