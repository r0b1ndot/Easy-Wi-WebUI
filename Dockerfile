FROM debian:jessie

MAINTAINER  Patrick Kerwood @ LinuxBloggen.dk <patirck@kerwood.dk>

RUN echo "mysql-server mysql-server/root_password password easywi" | debconf-set-selections \
	&& echo "mysql-server mysql-server/root_password_again password easywi" | debconf-set-selections \
	&& apt-get update && apt-get -y install apache2 php5 mysql-server php5-mysql php5-curl php5-gd unzip curl cron wget \
	&& wget https://easy-wi.com/de/downloads/get/3/ -O /home/easywi.zip

COPY startup.sh /
COPY easywi-cron /etc/cron.d/

VOLUME ["/var/lib/mysql", "/var/www/html"]
EXPOSE 8080
ENTRYPOINT ["/startup.sh"]
