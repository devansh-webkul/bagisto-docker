# container id
CONTAINER_ID=$(docker ps -aqf "name=mysql")

docker exec -it ${CONTAINER_ID} bash
