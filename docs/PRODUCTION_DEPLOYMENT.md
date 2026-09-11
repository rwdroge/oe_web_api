# Production Deployment Guide

## Overview
This guide covers deploying the GenericService application to production with:
- 1 Sports2020 database instance
- 2 PASOE instances (for load balancing/high availability)
- APSV transport support for direct AppServer calls
- WEB transport support for WebHandler REST API

## Prerequisites

### Software Requirements
- OpenEdge 12.x (with PASOE and RDBMS licenses)
- Progress.cfg license file with:
  - 4GL Development System
  - PASOE (Pacific Application Server for OpenEdge)
  - OE RDBMS
- Load balancer (optional but recommended for 2 PASOE instances)
- Operating System: Linux (recommended) or Windows Server

### Hardware Requirements (Minimum Production)
- **Database Server**: 4 CPU cores, 8GB RAM, 100GB storage (SSD recommended)
- **PASOE Instance 1**: 4 CPU cores, 8GB RAM, 50GB storage
- **PASOE Instance 2**: 4 CPU cores, 8GB RAM, 50GB storage

## Deployment Architecture

```
                    [Load Balancer]
                          |
          +---------------+---------------+
          |                               |
    [PASOE Instance 1]            [PASOE Instance 2]
    Port: 8810/8811               Port: 8820/8821
    APSV: enabled                 APSV: enabled
    WEB: enabled                  WEB: enabled
          |                               |
          +---------------+---------------+
                          |
                  [Sports2020 DB]
                    Port: 10000
```

## Directory Structure

Create the following directory structure on each server:

```
/opt/oe_web_api/
├── src/                    # Application source code
├── conf/                   # Configuration files
│   ├── as.pf              # AppServer parameter file
│   ├── db.pf              # Database connection parameter file
│   ├── openedge-pas1.properties # PASOE Instance 1 configuration
│   ├── openedge-pas2.properties # PASOE Instance 2 configuration
│   └── memProfConf        # Memory profiling config
├── lib/                   # Compiled .r and .pl files
├── logs/                  # Application logs
├── db/                    # Database files (on DB server only)
├── test/                  # Test procedures
└── scripts/               # Deployment and startup scripts
```

## Step-by-Step Deployment

### 1. Database Setup

#### Create Production Database
```bash
# On database server
cd /opt/oe_web_api/db
prodb sports2020 $DLC/sports2020
```

#### Configure Database for Multi-User Access
Edit `/opt/oe_web_api/scripts/start_db.sh`:
```bash
#!/bin/bash
# Start Sports2020 Database for Production
cd /opt/oe_web_api/db

# Start database with production parameters
proserve sports2020 \
  -S 10000 \
  -n 50 \
  -Mi 20 \
  -Ma 20 \
  -Mpb 100 \
  -B 20000 \
  -spin 10000000 \
  -cpinternal UTF-8 \
  -cpstream UTF-8 \
  -L 100000 \
  -lruskip \
  -ServerType 4GL
```

Make executable and start:
```bash
chmod +x /opt/oe_web_api/scripts/start_db.sh
/opt/oe_web_api/scripts/start_db.sh
```

#### Verify Database is Running
```bash
promon sports2020
# Or
proshut sports2020 -C list
```

### 2. Compile Application Code

Create `/opt/oe_web_api/scripts/compile_all.p`:
```abl
/* compile_all.p - Compile all application code for production */
DEFINE VARIABLE cFile AS CHARACTER NO-UNDO.
DEFINE VARIABLE cDir AS CHARACTER NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE iFiles AS INTEGER NO-UNDO.

OUTPUT TO "compile.log".

MESSAGE "Starting compilation at" STRING(NOW) SKIP.

/* Compile all .cls files */
INPUT FROM OS-DIR("src").
REPEAT:
    IMPORT cFile.
    IF cFile MATCHES "*.cls" THEN DO:
        MESSAGE "Compiling" cFile.
        COMPILE VALUE("src/" + cFile) SAVE.
        iFiles = iFiles + 1.
    END.
END.
INPUT CLOSE.

/* Compile all .p files */
INPUT FROM OS-DIR("src").
REPEAT:
    IMPORT cFile.
    IF cFile MATCHES "*.p" THEN DO:
        MESSAGE "Compiling" cFile.
        COMPILE VALUE("src/" + cFile) SAVE.
        iFiles = iFiles + 1.
    END.
END.
INPUT CLOSE.

MESSAGE "Compilation completed at" STRING(NOW) SKIP.
MESSAGE "Total files compiled:" iFiles.

OUTPUT CLOSE.
```

Run compilation:
```bash
cd /opt/oe_web_api
$DLC/bin/_progres -b -p scripts/compile_all.p -db sports2020 -H <db-host> -S 10000 -1
```

### 3. PASOE Instance 1 Configuration

#### Update openedge.properties for Instance 1
Location: `/opt/oe_web_api/conf/openedge-pas1.properties`

```properties
##########################################################################
# PASOE Instance 1 - Production Configuration
##########################################################################

[AppServer]
    allowRuntimeUpdates=0
    applications=pas
    collectMetrics=1
    statusEnabled=1

[AppServer.SessMgr]
    agentExecFile=${psc.as.oe.dlc}/bin/_mproapsv
    agentHost=
    agentListenerTimeout=300000
    agentLogEntryTypes=ASPlumbing,DB.Connects
    agentLogFile=${catalina.base}/logs/pas1.agent.log
    agentLoggingLevel=2
    agentStartLimit=3
    agentStartupParam=-T "${catalina.base}/temp" -pf /opt/oe_web_api/conf/as.pf
    agentWatchdogTimeout=3000
    connectionWaitTimeout=5000
    defaultAgentWaitAfterStop=30000
    defaultAgentWaitToFinish=30000
    idleAgentTimeout=1800000
    idleConnectionTimeout=300000
    idleResourceTimeout=0
    idleSessionTimeout=1800000
    ipver=IPv4
    maxABLSessionsPerAgent=200
    maxAgents=10
    maxConnectionsPerAgent=200
    minAgents=2
    numInitialAgents=2
    publishDir=${catalina.base}/openedge
    requestWaitTimeout=30000
    socketTimeout=5000
    tcpNoDelay=1

[AppServer.Agent]
    ablSessionActiveMemoryLimitFinish=0
    ablSessionActiveMemoryLimitStop=0
    ablSessionFailureLimit=0
    ablSessionMemoryDump=0
    ablSessionMemoryLimit=0
    ablSessionRequestLimit=0
    agentMaxPort=62202
    agentMinPort=62002
    agentShutdownProc=
    agentStartupProc=
    agentStartupProcParam=
    binaryUploadMaxSize=0
    collectStatsData=1
    completeActiveReqTimeout=600000
    fileUploadDirectory=
    flushStatsData=1
    infoVersion=9010
    lockAllExtLib=
    lockAllNonThreadSafeExtLib=
    messageReadTimeout=1000
    minAvailableABLSessions=2
    numInitialSessions=10
    PROPATH=/opt/oe_web_api/conf,/opt/oe_web_api/src,/opt/oe_web_api/lib,${DLC}/tty,${DLC}/tty/OpenEdge.Core.pl,${DLC}/tty/netlib/OpenEdge.Net.pl
    sessionActivateProc=
    sessionConnectProc=
    sessionDeactivateProc=
    sessionDisconnProc=
    sessionExecutionTimeLimit=0
    sessionShutdownProc=
    sessionStartupProc=
    sessionStartupProcParam=
    usingThreadSafeExtLib=
    uuid=
    workDir=${CATALINA_BASE}/work

[pas]
    webApps=ROOT

[pas.ROOT]
    allowRuntimeUpdates=0
    collectMetrics=1
    serviceFaultLevel=1
    statusEnabled=1

[AppServer.Agent.pas]
    numInitialSessions=10
    PROPATH=.,/opt/oe_web_api/conf,/opt/oe_web_api/src,/opt/oe_web_api/lib,${DLC}/tty,${DLC}/tty/OpenEdge.Core.pl,${DLC}/tty/netlib/OpenEdge.Net.pl
    uuid=http://pas-instance-1:8810/pas

[pas.ROOT.APSV]
    adapterEnabled=1
    enableRequestChunking=1
    oepingEnabled=1
    oepingProcedure=
    useHTTPSessions=1

[pas.ROOT.SOAP]
    adapterEnabled=0

[pas.ROOT.REST]
    adapterEnabled=1

[pas.ROOT.WEB]
    adapterEnabled=1
    defaultCookieDomain=
    defaultCookiePath=
    defaultHandler=OpenEdge.Web.CompatibilityHandler
    srvrAppMode=production
    srvrDebug=0
    wsRoot=/static/webspeed

[AppServer.SessMgr.pas]
    agentLogEntryTypes=ASPlumbing,DB.Connects
    agentLogFile=${catalina.base}/logs/pas1.agent.log
```

#### Update as.pf for Production
Location: `/opt/oe_web_api/conf/as.pf`

```
-db sports2020 -S 10000 -H <db-server-hostname>
-cpstream UTF-8
-cpinternal UTF-8
-n 100
-Bt 4096
-s 10
```

### 4. PASOE Instance 2 Configuration

Copy and modify for Instance 2:
```bash
cp /opt/oe_web_api/conf/openedge-pas1.properties /opt/oe_web_api/conf/openedge-pas2.properties
```

Update the following in `openedge-pas2.properties`:
- Change `pas1.agent.log` to `pas2.agent.log`
- Change `uuid=http://pas-instance-1:8810/pas` to `uuid=http://pas-instance-2:8820/pas`
- Adjust ports if running on same server (8820/8821 instead of 8810/8811)

### 5. Deploy PASOE Instances

#### Instance 1 Deployment
```bash
# Create PASOE instance
cd $DLC/bin
./tcman create -p 8810 -P 8811 /opt/oe_web_api/pas1

# Copy configuration
cp /opt/oe_web_api/conf/openedge-pas1.properties /opt/oe_web_api/pas1/conf/openedge.properties
cp /opt/oe_web_api/conf/as.pf /opt/oe_web_api/pas1/conf/

# Deploy application
cp -r /opt/oe_web_api/src/* /opt/oe_web_api/pas1/openedge/
cp -r /opt/oe_web_api/lib/* /opt/oe_web_api/pas1/openedge/

# Start instance
cd /opt/oe_web_api/pas1/bin
./tcman start
```

#### Instance 2 Deployment
```bash
# Create PASOE instance
cd $DLC/bin
./tcman create -p 8820 -P 8821 /opt/oe_web_api/pas2

# Copy configuration
cp /opt/oe_web_api/conf/openedge-pas2.properties /opt/oe_web_api/pas2/conf/openedge.properties
cp /opt/oe_web_api/conf/as.pf /opt/oe_web_api/pas2/conf/

# Deploy application
cp -r /opt/oe_web_api/src/* /opt/oe_web_api/pas2/openedge/
cp -r /opt/oe_web_api/lib/* /opt/oe_web_api/pas2/openedge/

# Start instance
cd /opt/oe_web_api/pas2/bin
./tcman start
```

### 6. Configure WebHandlers

Create `/opt/oe_web_api/src/webhandlers/ROOT.handlers`:
```
GenericService.cls : /api/*
```

Deploy to both instances:
```bash
cp /opt/oe_web_api/src/webhandlers/ROOT.handlers /opt/oe_web_api/pas1/webapps/ROOT/WEB-INF/
cp /opt/oe_web_api/src/webhandlers/ROOT.handlers /opt/oe_web_api/pas2/webapps/ROOT/WEB-INF/
```

### 7. Load Balancer Configuration (Optional)

Example NGINX configuration:
```nginx
upstream pasoe_backend {
    least_conn;
    server pas-instance-1:8810 max_fails=3 fail_timeout=30s;
    server pas-instance-2:8820 max_fails=3 fail_timeout=30s;
}

server {
    listen 80;
    server_name api.yourdomain.com;

    location /web/ {
        proxy_pass http://pasoe_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout 30s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }
}
```

## Testing Deployment

### Test WEB Transport (WebHandler)
```bash
# Test metadata endpoint
curl http://localhost:8810/web/api/meta/customers

# Test data endpoint
curl http://localhost:8810/web/api/data/customers

# Test on second instance
curl http://localhost:8820/web/api/meta/customers
```

### Test APSV Transport
See `test/test-apsv-connection.p` for APSV transport testing procedures.

## Monitoring and Maintenance

### Check PASOE Status
```bash
cd /opt/oe_web_api/pas1/bin
./tcman status

cd /opt/oe_web_api/pas2/bin
./tcman status
```

### View Logs
```bash
# Agent logs
tail -f /opt/oe_web_api/pas1/logs/pas1.agent.log
tail -f /opt/oe_web_api/pas2/logs/pas2.agent.log

# Application logs
tail -f /opt/oe_web_api/pas1/logs/catalina.out
tail -f /opt/oe_web_api/pas2/logs/catalina.out
```

### Restart Instances
```bash
# Instance 1
cd /opt/oe_web_api/pas1/bin
./tcman stop
./tcman start

# Instance 2
cd /opt/oe_web_api/pas2/bin
./tcman stop
./tcman start
```

## Security Considerations

1. **HTTPS Configuration**: Configure SSL/TLS certificates for production
2. **Authentication**: Implement proper authentication for API endpoints
3. **Database Security**: Use encrypted database connections
4. **Firewall Rules**: Restrict access to database and PASOE ports
5. **User Permissions**: Run PASOE instances with dedicated service accounts

## Backup Strategy

### Database Backups
```bash
# Daily incremental backup
probkup online sports2020 /backup/sports2020/incremental

# Weekly full backup
probkup sports2020 /backup/sports2020/full
```

### Application Backups
```bash
# Backup application code and configuration
tar -czf /backup/oe_web_api_$(date +%Y%m%d).tar.gz /opt/oe_web_api/src /opt/oe_web_api/conf
```

## Troubleshooting

### PASOE Won't Start
1. Check logs in `<instance>/logs/`
2. Verify database connectivity
3. Check PROPATH configuration
4. Verify license file

### Connection Errors
1. Verify database is running: `proshut sports2020 -C list`
2. Check network connectivity
3. Verify ports are not blocked by firewall
4. Check agent logs for connection errors

### Performance Issues
1. Monitor agent pool usage
2. Adjust `maxAgents` and `minAgents` settings
3. Check database performance
4. Review application logs for slow queries

## Production Checklist

- [ ] Database created and started with production parameters
- [ ] Application code compiled
- [ ] PASOE Instance 1 configured and started
- [ ] PASOE Instance 2 configured and started
- [ ] WebHandlers deployed to both instances
- [ ] WEB transport tested on both instances
- [ ] APSV transport tested on both instances
- [ ] Load balancer configured (if applicable)
- [ ] Monitoring configured
- [ ] Backup strategy implemented
- [ ] Security hardening completed
- [ ] Documentation updated with production URLs and credentials
