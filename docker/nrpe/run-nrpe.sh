#!/bin/bash

NRPE_EXEC="/sbin/nrpe"

$NRPE_EXEC -c $NAGIOS_CONF_DIR/nrpe.cfg -d

# Wait for NRPE Daemon to exit
PID=$(ps -ef | grep -v grep | grep  "${NRPE_EXEC}" | awk '{print $2}')
if [ ! "$PID" ]; then
  echo "Error: Unable to start nrpe daemon..."
  # exit 1
fi

tail -f /var/log/nrpe.log

echo "NRPE daemon exited. Quitting.."
