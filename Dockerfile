FROM ubuntu:18.04
MAINTAINER "Robert Kroon"

ARG RUBY_PATH
ENV PATH $RUBY_PATH/bin:$PATH

RUN apt-get update && apt-get install -y gnupg2 \
 && apt-get install software-properties-common -y \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E1DD270288B4E6030699E45FA1715D88E1DF1F24 \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 80F70E11F0F0D5F10CB20E62F5DA5F09C3173AA6 \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8B3981E7A6852F782CC4951600A6F0A3C300EE8C \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7 \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 \
 && echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
 && echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger bionic main" > /etc/apt/sources.list.d/passenger.list \
 && apt-get install -y apt-transport-https ca-certificates \
 && add-apt-repository ppa:nginx/stable \
 && apt-add-repository ppa:brightbox/ruby-ng \
 && apt-get update && apt-get install -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y git \
    netcat locales curl gcc make \
    libssl-dev zlib1g-dev nginx passenger \
    build-essential ruby2.4 ruby2.4-dev\
    libxml2 libxslt1.1 libpq-dev \
    imagemagick libmagickcore-dev libmagickwand-dev\
    wkhtmltopdf

RUN update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && locale-gen en_US.UTF-8 \
 && dpkg-reconfigure locales \
 && gem install --no-document bundler \
 && rm -rf /var/lib/apt/lists/*

# Use baseimage-docker's init process.
ADD docker/app_init /app_init
CMD ["/app_init"]

## Remove default site
RUN rm /etc/nginx/sites-enabled/default

# Configure Nginx
ADD docker/disable-version.conf /etc/nginx/conf.d/disable-version.conf
ADD docker/nginx-webapp.conf /etc/nginx/webapp.conf
ADD docker/nginx-env.conf /etc/nginx/main.d/env.conf
ADD docker/supervisord.nginx /etc/supervisor/conf.d/nginx.conf

RUN adduser --disabled-login --gecos 'Rails app' app && passwd -d app
RUN mkdir -p /home/app/webapp && chown app:app /home/app/webapp

RUN sed -i \
 -e "s|# passenger_|passenger_|" \
 -e "s|access_log /var/log/nginx/access.log;|access_log /dev/null;|" \
 -e "s|error_log /var/log/nginx/error.log;|error_log stderr;|" \
 -e "s|events {|include /etc/nginx/main.d/*.conf;\nerror_log /dev/stdout info;\nevents {|" \
 /etc/nginx/nginx.conf
