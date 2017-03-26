#!/bin/bash

###### Easy-Wi Webinterface container #######
# Author: Patrick Kerwood @ LinuxBloggen.dk #
#############################################

# Root password for MySQL
ROOT_PASS="easywi"

# MySQL volume folder
VOLUME_HOME="/var/lib/mysql"

# Apache document root
HTML_DIR="/var/www/html"

function SETUP_DB {

  # If the MySQL folder is empty (If the folder was mounted on host system)
  # Install a new database.
  if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo -e "\n=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo -e "=> Done!\n"

    # Run a temporary MySQL instance in safe mode.
    /usr/bin/mysqld_safe > /dev/null 2>&1 &

    # Wait for the instance to come up.
    RET=1
    while [[ RET -ne 0 ]]; do
        echo "=> Waiting for confirmation of MySQL service startup"
        sleep 2
        mysql -uroot -e "status" > /dev/null 2>&1
        RET=$?
    done

    # Set the debian-sys-maint password
    SYS_MAINT=$(cat /etc/mysql/debian.cnf | grep -m 1 password | cut -d" " -f 3)
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$SYS_MAINT';"



    # Set root password and showdown the temporary instance.
    mysqladmin -u root password $ROOT_PASS
    mysqladmin -uroot -p$ROOT_PASS shutdown

  else
    echo -e "\n=> Using an existing volume of MySQL\n"
  fi
}

function SETUP_EW {

  if [ ! -f $HTML_DIR/index.php ]; then

    if [ -f $HTML_DIR/index.html ]; then
      # Remove the standard index file.
      rm /var/www/html/index.html
    fi

    # Unzip Easy-Wi
    unzip /home/easywi.zip -d $HTML_DIR  > /dev/null
    chown -R www-data.www-data $HTML_DIR
  fi

  # Initiate some Easy-Wi scripts
  php /var/www/html/reboot.php >/dev/null 2>&1
  php /var/www/html/statuscheck.php >/dev/null 2>&1
  php /var/www/html/startupdates.php >/dev/null 2>&1
  php /var/www/html/jobs.php >/dev/null 2>&1
  php /var/www/html/cloud.php >/dev/null 2>&1

  echo "ServerName localhost" >> /etc/apache2/apache2.conf

  # Start MySQL
  /etc/init.d/mysql start

  if [ ! -d /var/lib/mysql/easywi ]; then
    # Create the Easy-Wi database
    mysql -u root -p$ROOT_PASS -e "create database easywi"
  fi

  touch /var/setup_complete
}

# Check if this is the first time the container is running
if [ ! -f /var/setup_complete ]; then
  SETUP_DB
  SETUP_EW
  echo -e "\nSetup is completed.."
fi
echo "Starting Cron"
/etc/init.d/cron start
echo
echo "Starting MySQL"
/etc/init.d/cron start
echo
echo "Starting Apache2..."
rm -f /var/run/apache2/apache2.pid
/usr/sbin/apache2ctl -D FOREGROUND
