#!/bin/bash

CONTAINER_NAME="php"

docker exec -w /var/www/html -u 0 -it $CONTAINER_NAME bash