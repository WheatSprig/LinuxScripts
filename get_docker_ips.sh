#!/bin/bash

echo "获取所有 Docker 运行的容器 IP 地址："
echo "-------------------------------------"

# 获取所有容器的 IP
docker ps -q | while read -r container_id; do
    container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's/^\///')
    container_ip=$(docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container_id")
    if [[ -n "$container_ip" ]]; then
        printf "%-30s %s\n" "$container_name" "$container_ip"
    fi
done

# 获取 Docker Compose 相关网络下的所有容器 IP
docker network ls --format '{{.Name}}' | while read -r network; do
    docker network inspect "$network" --format '{{range .Containers}}{{.Name}} {{.IPv4Address}}{{"\n"}}{{end}}'
done | while read -r container_name container_ip; do
    if [[ -n "$container_ip" ]]; then
        printf "%-30s %s\n" "$container_name" "${container_ip%/*}"  # 移除 CIDR 格式
    fi
done

echo "-------------------------------------"
