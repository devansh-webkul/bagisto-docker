#!/bin/bash

# Usage: ./supervisor.sh start|stop|restart

CONTAINER_NAME="php"
SUPERVISOR_CONF="/etc/supervisor/supervisord.conf"

case "$1" in
  start)
    docker exec -i -u 0 $CONTAINER_NAME bash -c "supervisord -c $SUPERVISOR_CONF"
    ;;
  stop)
    docker exec -i -u 0 $CONTAINER_NAME bash -c "supervisorctl shutdown"
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
