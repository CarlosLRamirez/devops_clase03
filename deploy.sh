#!/bin/bash

##definición de variables
REPO="The-DevOps-Journey-101"
user=$(id -u)

user=$(id -u)
echo $user


if [ "$(id -u)" -ne 0 ]; then
  echo -e "\033[33mCorrer con usuario ROOT\033[0m"
  exit
fi

echo "======================================================"

###update
echo -e "\e[92mActualizando paquetes ...\033[0m\n"
apt-get update
sleep 1
echo -e "\e[92mEl Servidor se encuentra Actualizado ...\033[0m\n"

##installing packages

echo -e "\n\e[96mAInstalando Git y Curl \033[0m\n"
apt install -y git curl
echo -e "\n\033[33mGit y Curl se han instalado\033[0m\n"

### base de datos
if dpkg -s mariadb-server > /dev/null 2>&1; then
  echo -e "\n\e[96mAMariadb esta realmente instalado \033[0m\n"
else
  echo -e "\n\e[92mInstalando mariadb ...\033[0m\n"
  apt install -y mariadb-server
  systemctl start mariadb
  systemctl enable mariadb
  sleep 1
  ##crear base de datos
  mysql -e "
    CREATE DATABASE ecomdb;
    CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
    GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
    FLUSH PRIVILEGES;"
  cat > db-load-script.sql <<-EOF

USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");
EOF

  echo -e "\n\033[33mScript sql generado\033[0m\n"
  mysql < db-load-script.sql
  echo -e "\n\033[33mScript sql ejecutado\033[0m\n"
fi

#### APACHE
if dpkg -s apache2 > /dev/null 2>&1; then
    echo -e "\n\e[96mApache esta realmente instalado \033[0m\n"
else
  apt install -y apache2
  apt install -y php libapache2-mod-php php-mysql
  echo "iniciando servicio de apache"
  sudo systemctl start apache2 
  sudo systemctl enable apache2 
  mv /var/www/html/index.html /var/www/html/index.html.bkp
fi

##web
echo -e "\n\e[92mInstalling web ...\033[0m\n"
slee 1
git clone https://github.com/roxsross/$REPO.git 
cp -r $REPO/CLASE-02/lamp-app-ecommerce/* /var/www/html
##actualizar index.php
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php
echo "====================================="

sleep 1

systemctl reload apache2

##test
echo "testiando web"
curl http://localhost