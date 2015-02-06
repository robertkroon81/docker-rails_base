FROM phusion/passenger-ruby21:0.9.15
MAINTAINER "Andres Koetsier"

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Build the latest Ruby 2.1
#RUN /pd_build/ruby2.1.sh

# Needed for checking db-migrations of rails project
RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y mysql-client

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable Nginx and Passenger
RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default

# Hard remove SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Configure Nginx
ADD docker/disable-version.conf /etc/nginx/conf.d/disable-version.conf
ADD docker/nginx-webapp.conf /etc/nginx/webapp.conf
ADD docker/nginx-env.conf /etc/nginx/main.d/env.conf
ADD docker/app_init /etc/my_init.d/app_init

RUN mkdir -p /home/app/webapp && chown app:app /home/app/webapp
