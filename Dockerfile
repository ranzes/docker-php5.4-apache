# Dockerfile written by 10up <sales@10up.com>
#
# Work derived from official PHP Docker Library:
# Copyright (c) 2014-2015 Docker, Inc.

FROM debian:stretch

# persistent / runtime deps
RUN apt-get update && apt-get install -y ca-certificates curl librecode0 libsqlite3-0 libxml2 --no-install-recommends && rm -r /var/lib/apt/lists/*

#RUN apt-get -y install nano build-essential checkinstall zip

#RUN apt-get -y install libfcgi-dev libfcgi0ldbl libjpeg62-dbg libmcrypt-dev libssl-dev

# phpize deps
RUN apt-get update && apt-get install -y autoconf file g++ gcc libc-dev make pkg-config re2c --no-install-recommends && rm -r /var/lib/apt/lists/*

ENV PHP_INI_DIR /usr/local/etc/php
RUN mkdir -p $PHP_INI_DIR/conf.d

##<autogenerated>##
RUN apt-get update && apt-get install -y apache2-bin apache2.2-common --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN apt-get install -y zlib1g-dev libicu-dev g++

RUN rm -rf /var/www/html && mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html && chown -R www-data:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html

# Apache + PHP requires preforking Apache for best results
RUN a2dismod mpm_event && a2enmod mpm_prefork

RUN mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.dist && rm /etc/apache2/conf-enabled/* /etc/apache2/sites-enabled/*
COPY apache2.conf /etc/apache2/apache2.conf
# it'd be nice if we could not COPY apache2.conf until the end of the Dockerfile, but its contents are checked by PHP during compilation

ENV PHP_EXTRA_BUILD_DEPS apache2-dev
ENV PHP_EXTRA_CONFIGURE_ARGS --with-apxs2
##</autogenerated>##

ENV GPG_KEYS F38252826ACD957EF380D39F2F7956BC5DA04B5D
RUN set -xe \
	&& for key in $GPG_KEYS; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done

ENV PHP_VERSION 5.4.45

# --enable-mysqlnd is included below because it's harder to compile after the fact the extensions are (since it's a plugin for several extensions, not an extension in itself)
RUN buildDeps=" \
		$PHP_EXTRA_BUILD_DEPS \
		bzip2 \
		libcurl4-openssl-dev \
		libreadline6-dev \
		librecode-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2-dev \
	" \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
	&& curl -SL "http://php.net/get/php-$PHP_VERSION.tar.bz2/from/this/mirror" -o php.tar.bz2 \
	&& curl -SL "http://php.net/get/php-$PHP_VERSION.tar.bz2.asc/from/this/mirror" -o php.tar.bz2.asc \
	&& gpg --verify php.tar.bz2.asc \
	&& mkdir -p /usr/src/php \
	&& tar -xof php.tar.bz2 -C /usr/src/php --strip-components=1 \
	&& rm php.tar.bz2* \
	&& cd /usr/src/php \
	&& ./configure \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		$PHP_EXTRA_CONFIGURE_ARGS \
		--enable-mysqlnd \
		--with-curl \
		--with-openssl \
		--with-readline \
		--with-recode \
		--with-zlib \
	        --with-freetype-dir \
                --enable-cgi \
                --enable-mbstring \
                --with-libxml \
                --enable-soap \
                --enable-calendar \
                --with-mcrypt \
                --enable-inline-optimization \
                --enable-sockets \
                --enable-sysvsem \
                --enable-sysvshm \
                --enable-pcntl \
                --enable-mbregex \
                --with-mhash \
                --enable-zip \
                --with-pcre-regex \
                --with-mysql \
                --with-pdo-mysql \
                --with-mysqli \
                --with-openssl \
                --enable-exif \
                --enable-dba \
                --with-gettext \
                --enable-shmop \
                --enable-sysvmsg \
                --enable-bcmath \
                --enable-ftp \
                --enable-intl \
                --with-pspell \
	&& make -j"$(nproc)" \
	&& make install \
	&& { find /usr/local/bin /usr/local/sbin -type f -executable -exec strip --strip-all '{}' + || true; } \
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false $buildDeps \
	&& make clean

COPY docker-php-ext-* /usr/local/bin/

##<autogenerated>##
COPY apache2-foreground /usr/local/bin/
RUN chmod +x /usr/local/bin/apache2-foreground /usr/local/bin/docker-php-ext-*
WORKDIR /var/www/html

# Enable apache2 rewrite engine
RUN a2enmod rewrite

RUN docker-php-ext-install mysql mysqli pdo pdo_mysql

# Change www-data user to match the host system UID and GID and chown www directory
RUN usermod --non-unique --uid 1000 www-data \
  && groupmod --non-unique --gid 1000 www-data \
  && chown -R www-data:www-data /var/www

EXPOSE 80
CMD ["apache2-foreground"]
##</autogenerated>##
