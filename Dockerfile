FROM debian:buster-slim
ENV DEBIAN_FRONTEND noninteractive

RUN useradd -m -u 1000 kubedrop

RUN apt-get update && \
    apt-get -yqq install apt-transport-https  ca-certificates unzip \
    wget curl git

RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/php.list && \
    apt-get -qq update && apt-get -qqy upgrade

ARG PHP_VERSION=7.4
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libapache2-mod-php${PHP_VERSION} \
    php${PHP_VERSION} \
    php${PHP_VERSION}-cgi \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-readline \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-xsl \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-mcrypt \
    php${PHP_VERSION}-apcu \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-ctype \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-ftp \
    php${PHP_VERSION}-fileinfo \
    php${PHP_VERSION}-iconv \
    php${PHP_VERSION}-pdo \
    php${PHP_VERSION}-phar \
    php${PHP_VERSION}-posix \
    php${PHP_VERSION}-simplexml \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-sockets \
    php${PHP_VERSION}-tokenizer \
    php${PHP_VERSION}-xmlreader \
    php${PHP_VERSION}-xmlwriter \
    php${PHP_VERSION}-mysqlnd \
    php${PHP_VERSION}-dev \
    default-mysql-client-core=1.0.5 \
    apache2 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN git clone https://github.com/drush-ops/drush.git /usr/local/src/drush && \
    cd /usr/local/src/drush && \
    git checkout 8.x && \
    ln -s /usr/local/src/drush/drush /usr/bin/drush && \
    composer install

RUN mkdir -p /var/www/project && a2enmod vhost_alias ssl rewrite headers

COPY app.conf /etc/apache2/sites-enabled/000-default.conf

EXPOSE 80

RUN chmod -R 0777 /var/tmp \
  && mkdir -p /var/run/apache2 \
  && chown -R kubedrop:kubedrop \
  /var/log \
  /var/lib/apache2 \
  /etc/apache2 \
  /var/run/apache2

USER kubedrop

CMD  /usr/sbin/apache2ctl -D FOREGROUND
