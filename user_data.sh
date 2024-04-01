#!/usr/bin/env bash

yum update -y

# INSTALANDO E CONFIGURANDO PARA QUE O DOCKER SEJA INICIADO JUNTO AO SISTEMA
yum install docker -y
systemctl start docker.service
systemctl enable docker.service

# INSTALANDO O DOCKER-COMPOSE
curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

# INSTALANDO NFS
yum install nfs-utils -y
systemctl start nfs-utils.service
systemctl enable nfs-utils.service
mkdir -p /efs

# MONTANDO AUTOMATICAMENTE O EFS
echo "fs-05aa9716a33be6d92.efs.us-east-1.amazonaws.com:/ /efs nfs defaults 0 0" >> /etc/fstab
mount -a

# CRIANDO O DIRETORIO DO WP
mkdir -p /efs/wordpress

# CONFIG O DOCKER-COMPOSE
services:
  wordpress:
    image: wordpress:latest
    volumes:
      - /efs/wordpress:/var/www/html
    ports:
      - 80:80
    restart: always
    environment:
      WORDPRESS_DB_HOST: # [RDS ENDPOINT]
      WORDPRESS_DB_USER: # [RDS USER]
      WORDPRESS_DB_PASSWORD: # [USER PASSWORD]
      WORDPRESS_DB_NAME: # [RDS INITIAL NAME]

docker-compose -f /efs/docker-compose.yml up -d