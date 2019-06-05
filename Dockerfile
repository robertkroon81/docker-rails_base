FROM debian
MAINTAINER "Robert Kroon"

ARG RUBY_PATH
ENV PATH $RUBY_PATH/bin:$PATH

RUN apt-get update && apt-get install -y gnupg2 \
 && apt-get install software-properties-common -y \
 && apt-get update && apt-get install -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y git \
    netcat locales curl gcc make \
    libssl-dev zlib1g-dev nginx passenger \
    build-essential\
    libxml2 libxslt1.1 libpq-dev \
    imagemagick libmagickcore-dev libmagickwand-dev\
    wkhtmltopdf \
 && gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN \curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.4.5"
RUN /bin/bash -l -c "gem install bundler"

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
