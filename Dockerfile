FROM phusion/passenger-ruby21:0.9.14
MAINTAINER Andres Koetsier

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Build the latest Ruby 2.1
RUN /build/ruby2.1.sh

# Needed for checking db-migrations of rails project
RUN apt-get update
RUN apt-get install -y mysql-client

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable Nginx and Passenger
RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default

# Configure Nginx
ADD docker/disable-version.conf /etc/nginx/conf.d/disable-version.conf
ADD docker/nginx-webapp.conf /etc/nginx/webapp.conf
ADD docker/nginx-env.conf /etc/nginx/main.d/env.conf
ADD docker/app_init /etc/my_init.d/app_init

USER app
RUN mkdir /home/app/webapp
