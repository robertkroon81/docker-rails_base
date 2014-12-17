# Docker Rails base

A Docker base image we use for our projects. Based on the Passenger-docker image from Phusion.

This image enabled nginx, creates a vhost and will modify the rails-env of the vhost on start. It will check for pending migrations. Use DB_HOST, DB_NAME, DB_USER and DB_PASS environment variables to configure the db and supply a SECRET_KEY_BASE for rails.
