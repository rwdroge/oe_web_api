#!/bin/bash

function startServer() {
    if [[ -f "${PASWEBHANDLERS}" ]]; then
        echo "start.sh: $PASWEBHANDLERS found, copying to /app/pas/as/webapps/ROOT/WEB-INF/adapters/web/ROOT/"
        cp ${PASWEBHANDLERS} /app/pas/as/webapps/ROOT/WEB-INF/adapters/web/ROOT/
        cat /app/pas/as/webapps/ROOT/WEB-INF/adapters/web/ROOT/ROOT.handlers
    else
        echo "start.sh: $PASWEBHANDLERS not found, using default"
        ls -l /app/src/webhandlers/ 2>&1 || echo "webhandlers directory not found"
    fi

    if [[ -f "/app/scripts/pas-start.sh" ]]; then
        echo "start.sh: running /app/scripts/pas-start.sh"
        /app/scripts/pas-start.sh
    else
        echo "start.sh: /app/scripts/pas-start.sh not found"
    fi

    /app/pas/as/bin/tcman.sh start -v
    echo "start.sh: PAS instance started..."
    ps -ef
}

function stopServer() {
    echo "start.sh: attempt to bring PAS instance down gracefully"

    if [[ -f "/app/scripts/pas-stop.sh" ]]; then
        echo "start.sh: running /app/scripts/pas-stop.sh"
        /app/scripts/pas-stop.sh
    else
        echo "start.sh: /app/scripts/pas-stop.sh not found"
    fi
    
    /app/pas/as/bin/tcman.sh stop
    echo "start.sh: PAS stopped..."
    exit 0
}

function initLicense() {
    echo "checking for license"
    if [[ -f /app/license/progress.cfg ]]; then
        echo "license found in /app/license, copying to /usr/dlc/progress.cfg"
        cp /app/license/progress.cfg $DLC/progress.cfg
    fi
    if [[ ! -f $DLC/progress.cfg ]]; then
        echo "No license (/usr/dlc/progress.cfg) found, exiting..."
        exit 1
    fi  
    echo "license found, proceeding"
}

trap "stopServer" SIGINT SIGTERM
echo "hier ben ik"

initLicense
startServer

# Wait for PASOE to fully initialize
sleep 5

# Keep container running by waiting on the Java process
echo "start.sh: Monitoring PASOE Java process..."
while pgrep -f "org.apache.catalina.startup.Bootstrap" > /dev/null; do
    sleep 5
done

echo "start.sh: PASOE process ended, shutting down container"
exit 0
