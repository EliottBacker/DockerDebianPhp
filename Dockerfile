FROM debian:jessie

MAINTAINER Eliott BACKER "eliott.backer@gmail.com"

# Update repositories cache and distribution
RUN apt-get -qq update

# Install some basic tools needed for deployment
RUN apt-get -yqq install wget curl nano git apt-utils

# Add Public Key
RUN curl https://www.dotdeb.org/dotdeb.gpg -o /tmp/dotdeb.gpg
RUN apt-key add /tmp/dotdeb.gpg && rm /tmp/dotdeb.gpg
ADD https://www.dotdeb.org/dotdeb.gpg /dotdeb.gpg
RUN apt-key add dotdeb.gpg

# Update repositories cache and distribution
RUN apt-get -qq update

# Set repositories
RUN echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list 
RUN echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list 

# Update repositories cache and distribution
RUN apt-get -qq update

RUN apt-get -yqq install apache2 && \
  a2enmod proxy && \
  a2enmod proxy_http && \
  a2enmod authn_core && \
  a2enmod alias && \
  a2enmod headers && \
  a2enmod authz_core && \
  a2enmod authz_host && \
  a2enmod authz_user && \
  a2enmod dir && \
  a2enmod env && \
  a2enmod mime && \
  a2enmod reqtimeout && \
  a2enmod rewrite && \
  a2enmod deflate && \
  a2enmod ssl

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

# PHP Timezone
RUN echo $TZ | tee /etc/timezone && \
  dpkg-reconfigure --frontend noninteractive tzdata && \
  echo "date.timezone = \"$TZ\";" > /etc/php/7.0/apache2/conf.d/timezone.ini && \
  echo "date.timezone = \"$TZ\";" > /etc/php/7.0/cli/conf.d/timezone.ini
    
# Install composer (latest version)
RUN curl -sS https://getcomposer.org/installer | php && \
mv composer.phar /usr/local/bin/composer
    
RUN echo Europe/Paris > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

RUN rm /etc/apache2/sites-enabled/000-default.conf && \
    rm /etc/apache2/sites-available/000-default.conf

# Cleanup some things.
RUN apt-get autoremove -y
RUN apt-get clean 
RUN rm -rf /var/lib/apt/lists

# Expose apache.
EXPOSE 80 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
