FROM php:7.4-fpm-buster

# Install utility and libs needed by PHP extension
RUN apt-get update && apt-get install -y \
    build-essential \
    zlib1g-dev \
    libzip-dev \
    xfonts-base \
    xfonts-75dpi\
    unzip \
    unoconv \
    multiarch-support \
    ca-certificates \
    git \
    wget && \
    apt-get install -y --force-yes libreoffice --no-install-recommends && \
    curl "https://archive.debian.org/debian/pool/main/libp/libpng/libpng12-0_1.2.50-2+deb8u3_amd64.deb" -L -o "libpng12.deb" && \
    dpkg -i libpng12.deb && \
    rm -rf libpng12.deb && \
    curl "https://archive.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1e-2+deb7u20_amd64.deb" -L -o "libssl1.deb" && \
    dpkg -i libssl1.deb && \
    rm -rf libssl1.deb && \
    curl "https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.2.1/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb" -L -o "wkhtmltox.deb" && \
    dpkg -i wkhtmltox.deb && \
    rm -rf wkhtmltox.deb && \
    rm -rf /var/lib/apt/lists/*

# install some base extensions
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && IPE_GD_WITHOUTAVIF=1 install-php-extensions gmp gd zip pdo_mysql pdo_pgsql pgsql pcntl mcrypt

# install composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# install pear extensions
RUN pear channel-update pear.php.net && pear install Numbers_Words-0.18.1

# install libsodium
RUN wget --secure-protocol=TLSv1_2 https://download.libsodium.org/libsodium/releases/libsodium-1.0.18-stable.tar.gz && \
    tar xzvf libsodium-1.0.18-stable.tar.gz && \
    cd libsodium-stable/ && \
    ./configure && \
    make && \
    make check && \
    make install && \
    pecl install libsodium && \
    cd .. && \
    rm -rf libsodium-1.0.18-stable.tar.gz libsodium-stable