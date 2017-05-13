FROM debian:jessie

MAINTAINER Eliott BACKER "eliott.backer@gmail.com"

# no question/dialog is asked during apt-get install
ENV DEBIAN_FRONTEND noninteractive

# Locale
ENV LOCALE fr_FR.UTF-8

# PHP Timezone
ENV TZ=Europe/Paris

# Add Public Key (dotdeb)
RUN apt-get -qq update

# Install some basic tools needed for deployment
RUN apt-get -yqq install wget curl nano git apt-utils

# Add Public Key
RUN curl https://www.dotdeb.org/dotdeb.gpg -o /tmp/dotdeb.gpg
RUN apt-key add /tmp/dotdeb.gpg && rm /tmp/dotdeb.gpg
ADD https://www.dotdeb.org/dotdeb.gpg /dotdeb.gpg
RUN apt-key add dotdeb.gpg
RUN apt-get -qq update

# Set repositories
RUN echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list 
RUN echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list 

# Update repositories cache and distribution
RUN apt-get -yqq update


# Install apache
RUN apt-get -yqq install apache2 

# Install PHP7
RUN apt-get -yqq install \
    php7.0 \
    php7.0-curl \
    php7.0-intl \
    php7.0-json \
    php7.0-mbstring \
    php7.0-mcrypt \
    php7.0-mysql \
    php7.0-ssh2 \
    php7.0-xml \
    php7.0-zip \
    php7.0-opcache \
    php7.0-memcache \
    php7.0-memcached \
    libapache2-mod-php7.0

Run echo "ServerName localhost" >> /etc/apache2/httpd.conf

# PHP Timezone
RUN echo $TZ | tee /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    echo "date.timezone = \"$TZ\";" > /etc/php/7.0/apache2/conf.d/timezone.ini && \
    echo "date.timezone = \"$TZ\";" > /etc/php/7.0/cli/conf.d/timezone.ini
  
# Enable apache mods
RUN a2enmod \
    headers \
    rewrite 
RUN a2dismod cgi
  
# Install composer (latest version)
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer
  
# Cleanup some things.
RUN apt-get autoremove -y
RUN apt-get clean 
RUN rm -rf /var/lib/apt/lists

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR

# Copy this repo into place.
ADD www /var/www/site

# Update the default apache site with the config we created.
ADD conf/default.conf /etc/apache2/sites-enabled/000-default.conf

RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

RUN rm /etc/apache2/sites-enabled/000-default.conf && \
    rm /etc/apache2/sites-available/000-default.conf

# Expose apache.
EXPOSE 80 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
