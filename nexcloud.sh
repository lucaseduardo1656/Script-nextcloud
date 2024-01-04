#!/bin/bash

# Author: led - for glory of the shell!!

banner () {        ##### Banner #####
echo -e "
     ______                      _                      _ _             
    |  ___ \             _      (_)           _        | | |            
    | |   | | ____ _   _| |_     _ ____   ___| |_  ____| | | ____  ____ 
    | |   | |/ _  | \ / )  _)   | |  _ \ /___)  _)/ _  | | |/ _  )/ ___)
    | |   | ( (/ / ) X (| |__   | | | | |___ | |_( ( | | | ( (/ /| |    
    |_|   |_|\____|_/ \_)\___)  |_|_| |_(___/ \___)_||_|_|_|\____)_|   "
echo -e " \n                     for glory of the shell!!"
}

menu () {        ##### Display available options #####
echo -e "\n                   [ Select Option To Continue ]\n\n"
echo -e "      [1] start installation"
echo -e "      [2] Uninstall installation"
echo -e "      [3] Web Config"
echo -e "      [4] How it works?"
echo -e "      [5] Exit\n\n"
while true; do
read -p "Select Option: " option
case $option in
  1) echo -e "\n Option 1 Starting installation..."
     initialstart
     ;;
  2) echo -e "\n Option 2 Uninstall..."
     remove
     exit 0
     ;;        
  3) echo -e "\n Option 2 Web config..."
     webconfig
     exit 0
     ;;     
  4) echo -e "\n Option 3 help..."
     help
     exit 0
     ;;
  5) echo -e "\nThank You for using the script!"
     exit 0
     ;;
  *) echo -e "Please select correct option...\n"
     ;;
esac
done
}

PACOTE_MANAGER=""
# Função para identificar o gerenciador de pacotes
get_package_manager() {
    if command -v apt &>/dev/null; then
        PACKAGE_MANAGER="apt"
    elif command -v dnf &>/dev/null; then
        PACKAGE_MANAGER="dnf"
    elif command -v yum &>/dev/null; then
        PACKAGE_MANAGER="yum"
    elif command -v zypper &>/dev/null; then
        PACKAGE_MANAGER="zypper"
    elif command -v pacman &>/dev/null; then
        PACKAGE_MANAGER="pacman"
    elif command -v apk &>/dev/null; then
        PACKAGE_MANAGER="apk"
    elif command -v pkg &>/dev/null; then
        PACKAGE_MANAGER="pkg"
    else
        echo "Não foi possível identificar o gerenciador de pacotes."
        exit 1
    fi
    export PACKAGE_MANAGER
}

remove() {
    echo -e "\nRemoving Nextcloud installation..."

    sudo $PACKAGE_MANAGER remove -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2

    echo "Stopping Apache service..."
    sudo service apache2 stop 

    echo "Removing Nextcloud files..."
    sudo rm -rf /var/www/html/nextcloud

    echo "Removing Apache and PHP packages..."
    sudo $PACKAGE_MANAGER remove apache2 -y
    sudo $PACKAGE_MANAGER remove libapache2-mod-php8.0 -y

    echo "Removing MariaDB packages..."
    sudo $PACKAGE_MANAGER remove mariadb-server mariadb-client -y

    echo "Cleaning up system..."
    sudo $PACKAGE_MANAGER autoremove -y
    sudo $PACKAGE_MANAGER autoclean

    echo "Nextcloud removal complete."
}

webconfig (){
    clear
    echo -e "\nthe defalt valure of the data base is"
    echo -e "\nUser : ncadmin@127.0.0.1"
    echo -e "Data Base : ncdb"
    echo -e "Password : nextclouddbpw"
}

help(){
    echo -e "\n This script automates the installation of Nextcloud on a Linux server, including necessary dependencies and configurations."

    echo -e "\n How it works:\n"
    echo -e "1. The script determines the package manager available on the system (apt, dnf, yum, zypper, pacman, apk, pkg)."
    echo -e "2. Installs necessary commands, updates the package manager, and installs required certificates."
    echo -e "3. Installs PHP and its extensions, MariaDB (as the database), and Apache2 (as the web server)."
    echo -e "4. Downloads the latest Nextcloud release, extracts it, and moves it to the appropriate web server directory."
    echo -e "5. Configures the database and web server settings."
    echo -e "6. Restarts the Apache2 service and provides instructions to configure Nextcloud through the web interface.\n"

}

initialstart(){
    get_package_manager
    if [ -n "$PACKAGE_MANAGER" ]; then
        echo "install required commands using $PACKAGE_MANAGER..."

        $PACKAGE_MANAGER install unzip

        sudo $PACKAGE_MANAGER update

        echo certificates installation
        
        sudo $PACKAGE_MANAGER install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2
        
        sudo $PACKAGE_MANAGER sudo update
        
        sudo $PACKAGE_MANAGER install -y php8.2 php8.2-gd php8.2-curl php8.2-zip php8.2-dom php8.2-xml php8.2-simplexml php8.2-mbstring php8.2-mysql 

        echo database installation and configuration used mariadb
        
        $PACKAGE_MANAGER install mariadb-server mariadb-client -y

        mysql -u root -e"CREATE USER ncadmin@127.0.0.1";

        mysql -u root -e"CREATE DATABASE ncdb";

        mysql -u root -e"GRANT ALL ON ncdb.* TO 'ncadmin'@'127.0.0.1' IDENTIFIED BY 'nextclouddbpw'";

        mysql -u root -e"FLUSH PRIVILEGES";

        echo "webserver installation (apache2)"

        $PACKAGE_MANAGER install apache2 -y

        $PACKAGE_MANAGER install libapache2-mod-php8.0

        echo download nextcloud

        cd /tmp

        wget https://download.nextcloud.com/server/releases/latest.tar.bz2

        tar -xf latest.tar.bz2

        mv nextcloud /var/www/html

        cd /var/www/html

        sudo chown -R www-data:www-data nextcloud

        sudo chmod -R 755 nextcloud

        service apache2 restart

        echo configure database on webinterface domain/nextcloud/index.php

        echo "Thank you, we're done here, configure nextcloud on webinterface (domain/nextcloud)"
        fi
    
    exit 0
}

verify_sudo() {
    if [ "$(id -u)" != "0" ]; then
        echo "Please run this script with superuser instructions (sudo)." >&2
        exit 1
    fi
}


main() {
    clear
    verify_sudo
    banner
    menu
}

main
