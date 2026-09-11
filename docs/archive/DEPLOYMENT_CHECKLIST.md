# Production Deployment Checklist

## Pre-Deployment

### Infrastructure
- [ ] Database server provisioned (4 CPU, 8GB RAM minimum)
- [ ] PASOE Instance 1 server provisioned (4 CPU, 8GB RAM minimum)
- [ ] PASOE Instance 2 server provisioned (4 CPU, 8GB RAM minimum)
- [ ] Load balancer configured (optional but recommended)
- [ ] Network connectivity verified between all servers
- [ ] Firewall rules configured:
  - [ ] Database port 10000 accessible from PASOE servers
  - [ ] PASOE ports 8810/8811 accessible from load balancer
  - [ ] PASOE ports 8820/8821 accessible from load balancer

### Software Installation
- [ ] OpenEdge 12.x installed on all servers
- [ ] Progress.cfg license file deployed with required products:
  - [ ] 4GL Development System
  - [ ] PASOE
  - [ ] OE RDBMS
- [ ] Required system packages installed (curl, bash, etc.)

### Configuration Files
- [ ] `conf/as.pf` updated with correct database hostname
- [ ] `conf/openedge-pas1.properties` reviewed and customized
- [ ] `conf/openedge-pas2.properties` reviewed and customized
- [ ] `src/webhandlers/ROOT.handlers` configured

## Deployment Steps

### 1. Database Setup
- [ ] Sports2020 database created
- [ ] Database started with production parameters
- [ ] Database connectivity tested from PASOE servers
- [ ] Database backup strategy implemented
- [ ] Database monitoring configured

### 2. Application Compilation
- [ ] Source code deployed to `/opt/oe_web_api/src`
- [ ] Compilation script executed successfully
- [ ] No compilation errors in `logs/compile.log`
- [ ] Compiled .r files present in source directories

### 3. PASOE Instance 1 Deployment
- [ ] PASOE instance created at configured path
- [ ] Configuration files deployed
- [ ] Application code deployed to `openedge/` directory
- [ ] WebHandlers deployed to `webapps/ROOT/WEB-INF/`
- [ ] Instance started successfully
- [ ] Instance status verified with `tcman status`

### 4. PASOE Instance 2 Deployment
- [ ] PASOE instance created at configured path
- [ ] Configuration files deployed
- [ ] Application code deployed to `openedge/` directory
- [ ] WebHandlers deployed to `webapps/ROOT/WEB-INF/`
- [ ] Instance started successfully
- [ ] Instance status verified with `tcman status`

### 5. Transport Configuration
- [ ] APSV adapter enabled in both instances
- [ ] WEB adapter enabled in both instances
- [ ] REST adapter enabled in both instances
- [ ] SOAP adapter disabled (if not needed)

## Testing

### WEB Transport (WebHandler) Tests
- [ ] Instance 1 - GET metadata: `curl http://localhost:8810/web/api/meta/customers`
- [ ] Instance 1 - GET data: `curl http://localhost:8810/web/api/data/customers`
- [ ] Instance 2 - GET metadata: `curl http://localhost:8820/web/api/meta/customers`
- [ ] Instance 2 - GET data: `curl http://localhost:8820/web/api/data/customers`
- [ ] POST request tested (create customer)
- [ ] PUT request tested (update customer)
- [ ] DELETE request tested (delete customer)

### APSV Transport Tests
- [ ] Connection test executed: `_progres -p test/test-apsv-connection.p`
- [ ] Data access test executed: `_progres -p test/test-apsv-data-access.p`
- [ ] All APSV tests passed on Instance 1
- [ ] All APSV tests passed on Instance 2
- [ ] Complete test suite executed: `_progres -p test/run-all-apsv-tests.p`

### Load Balancer Tests (if applicable)
- [ ] Load balancer health checks configured
- [ ] Requests distributed across both instances
- [ ] Failover tested (stop one instance)
- [ ] Session persistence tested (if required)

### Performance Tests
- [ ] Response time under normal load acceptable
- [ ] Response time under peak load acceptable
- [ ] Agent pool sizing adequate (no agent starvation)
- [ ] Database connection pool adequate
- [ ] Memory usage within acceptable limits

## Security

### Application Security
- [ ] HTTPS configured with valid SSL certificates
- [ ] Authentication mechanism implemented
- [ ] Authorization rules configured
- [ ] API rate limiting configured (if applicable)
- [ ] Input validation enabled

### System Security
- [ ] PASOE instances running as dedicated service accounts
- [ ] Database access restricted to PASOE servers only
- [ ] Unnecessary services disabled
- [ ] Security patches applied
- [ ] Audit logging enabled

### Network Security
- [ ] Firewall rules restrict access to required ports only
- [ ] Database port not exposed to public internet
- [ ] VPN or private network used for inter-server communication
- [ ] DDoS protection configured (if applicable)

## Monitoring

### Application Monitoring
- [ ] PASOE agent logs monitored
- [ ] Application error logs monitored
- [ ] API endpoint health checks configured
- [ ] Response time monitoring configured
- [ ] Error rate monitoring configured

### System Monitoring
- [ ] CPU usage monitoring
- [ ] Memory usage monitoring
- [ ] Disk space monitoring
- [ ] Network traffic monitoring
- [ ] Database performance monitoring

### Alerting
- [ ] Critical alerts configured (service down)
- [ ] Warning alerts configured (high resource usage)
- [ ] Alert notification channels configured
- [ ] On-call rotation established

## Backup and Recovery

### Database Backups
- [ ] Daily incremental backup scheduled
- [ ] Weekly full backup scheduled
- [ ] Backup retention policy defined
- [ ] Backup restoration tested
- [ ] Backup monitoring configured

### Application Backups
- [ ] Source code backed up
- [ ] Configuration files backed up
- [ ] Backup storage location secured
- [ ] Backup restoration procedure documented

### Disaster Recovery
- [ ] Disaster recovery plan documented
- [ ] Recovery Time Objective (RTO) defined
- [ ] Recovery Point Objective (RPO) defined
- [ ] DR testing scheduled

## Documentation

### Technical Documentation
- [ ] Architecture diagram created
- [ ] Network diagram created
- [ ] Configuration settings documented
- [ ] PROPATH configuration documented
- [ ] Database connection parameters documented

### Operational Documentation
- [ ] Startup procedures documented
- [ ] Shutdown procedures documented
- [ ] Restart procedures documented
- [ ] Troubleshooting guide created
- [ ] Escalation procedures defined

### User Documentation
- [ ] API documentation published
- [ ] Authentication guide provided
- [ ] Example requests documented
- [ ] Error codes documented

## Post-Deployment

### Verification
- [ ] All endpoints responding correctly
- [ ] No errors in application logs
- [ ] No errors in agent logs
- [ ] Database connections stable
- [ ] Performance metrics within acceptable range

### Handover
- [ ] Operations team trained
- [ ] Access credentials provided
- [ ] Support contacts documented
- [ ] Escalation procedures communicated

### Maintenance
- [ ] Maintenance windows scheduled
- [ ] Update procedures documented
- [ ] Rollback procedures documented
- [ ] Change management process established

## Sign-Off

### Technical Sign-Off
- [ ] Database Administrator: _________________ Date: _______
- [ ] Application Administrator: ______________ Date: _______
- [ ] Network Administrator: __________________ Date: _______
- [ ] Security Administrator: _________________ Date: _______

### Business Sign-Off
- [ ] Project Manager: _______________________ Date: _______
- [ ] Product Owner: _________________________ Date: _______
- [ ] Operations Manager: ____________________ Date: _______

## Notes

### Issues Encountered
```
[Document any issues encountered during deployment and their resolutions]
```

### Deviations from Plan
```
[Document any deviations from the original deployment plan]
```

### Lessons Learned
```
[Document lessons learned for future deployments]
```

## Quick Reference

### Important URLs
- **Instance 1 WEB**: http://localhost:8810/web/api/
- **Instance 1 APSV**: http://localhost:8810/pas/apsv
- **Instance 2 WEB**: http://localhost:8820/web/api/
- **Instance 2 APSV**: http://localhost:8820/pas/apsv
- **Load Balancer**: http://api.yourdomain.com/

### Important Commands
```bash
# Check PASOE status
cd /opt/oe_web_api/pas1/bin && ./tcman status

# Restart PASOE
cd /opt/oe_web_api/pas1/bin && ./tcman restart

# Check database status
proshut sports2020 -C list

# View agent logs
tail -f /opt/oe_web_api/pas1/logs/pas1.agent.log

# Run APSV tests
_progres -p test/run-all-apsv-tests.p -param "http://localhost:8810/pas/apsv"
```

### Important Files
- Configuration: `/opt/oe_web_api/conf/openedge-pas1.properties`
- Agent logs: `/opt/oe_web_api/pas1/logs/pas1.agent.log`
- Application logs: `/opt/oe_web_api/pas1/logs/catalina.out`
- Database: `/opt/oe_web_api/db/sports2020.db`
