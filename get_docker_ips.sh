#!/bin/bash

echo "获取 Docker 运行的容器 IP 地址："
docker ps -q | while read -r container_id; do
    container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's/^\///')
    container_ip=$(docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_id")
    echo "$container_name: $container_ip"
done

echo -e "\n获取 Docker Compose 运行的容器 IP 地址："
docker network ls --format '{{.Name}}' | while read -r network; do
    docker network inspect "$network" --format '{{range .Containers}}{{.Name}}: {{.IPv4Address}}{{"\n"}}{{end}}'
done
