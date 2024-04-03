#!/usr/bin/env bash

yum update -y

# INSTALANDO E CONFIGURANDO PARA QUE O DOCKER SEJA INICIADO JUNTO AO SISTEMA
yum install docker libxcrypt-compat -y
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
echo "fs-057fe62fef337ad15.efs.us-east-1.amazonaws.com:/ /efs nfs defaults 0 0" >> /etc/fstab
mount -a

# CRIANDO O DIRETORIO DO WP
mkdir -p /efs/wordpress

# DANDO PERMISSAO AO DEFAULT USER
sudo usermod -aG docker ec2-user
sudo chmod 666 /var/run/docker.sock

# CONFIG O DOCKER-COMPOSE
cat <<EOL > /efs/docker-compose.yml
version: "3.8"
services:
  wordpress:
    image: wordpress:latest
    volumes:
      - /efs/wordpress:/var/www/html
    ports:
      - 80:80
    restart: always
    environment:
      WORDPRESS_DB_HOST: wordpress.c3aa04ioyfq6.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: admin
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress
EOL

docker-compose -f /efs/docker-compose.yml up -d
