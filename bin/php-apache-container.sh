# container id
CONTAINER_ID=$(docker ps -aqf "name=php-apache")

docker exec -u $USER -w /var/www/html -it ${CONTAINER_ID} bash
