#!/bin/bash

echo "获取所有 Docker 运行的容器 IP 地址："
echo "-------------------------------------"

declare -A container_ips  # 创建关联数组存储容器的 IP

# 获取所有运行的容器 ID
for container_id in $(docker ps -q); do
    container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's/^\///')
    container_ip_list=$(docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' "$container_id")

    # 处理 IP，去掉多余空格并去重
    if [[ -n "$container_ip_list" ]]; then
        container_ips["$container_name"]="${container_ips["$container_name"]} $container_ip_list"
    fi
done

# 获取 Docker Compose 相关网络下的所有容器 IP
for network in $(docker network ls --format '{{.Name}}'); do
    while read -r container_name container_ip; do
        container_ip=${container_ip%/*}  # 去掉 CIDR 子网信息
        if [[ -n "$container_ip" ]]; then
            container_ips["$container_name"]="${container_ips["$container_name"]} $container_ip"
        fi
    done < <(docker network inspect "$network" --format '{{range .Containers}}{{.Name}} {{.IPv4Address}}{{"\n"}}{{end}}')
done

# 输出结果
for container in "${!container_ips[@]}"; do
    ip_list=$(echo "${container_ips[$container]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
    printf "%-30s %s\n" "$container" "$ip_list"
done

echo "-------------------------------------"
