#!/bin/bash
# Reset all nova database settings and restart the services

# Update the database
sudo mysql -u root -e "DROP DATABASE nova;"
sudo mysql -u root -e "CREATE DATABASE nova;"

# Sync up the table definitions
nova-manage db sync
# Create a default set of fixed and floating ips
nova-manage network create 10.0.0.0/24 1 32
nova-manage floating create `hostname` 10.6.0.0/27
# Create a default admin user and a project and assign the admin user to it
nova-manage user admin admin admin admin
nova-manage project create admin admin

# Restart all the services
sudo service nova-api restart
sudo service nova-scheduler restart
sudo service nova-network restart
sudo service nova-volume restart
sudo service nova-compute restart
