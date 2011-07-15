#!/bin/bash
# Reset all nova database settings and restart the services

# Update the database
mysql -u nova -pnova -e "DROP DATABASE nova;"
mysql -u nova -pnova -e "CREATE DATABASE nova;"

cd /home/nova/nova/trunk

# Sync up the table definitions
sudo bin/nova-manage --flagfile=etc/nova.conf db sync
# Create a default set of fixed and floating ips
sudo bin/nova-manage --flagfile=etc/nova.conf network create private 10.0.0.0/24 1 32 0 0 0 0 br100 eth0
sudo bin/nova-manage --flagfile=etc/nova.conf floating create 10.6.0.0/27
# Create a default admin user and a project and assign the admin user to it
sudo bin/nova-manage --flagfile=etc/nova.conf user admin admin admin admin
sudo bin/nova-manage --flagfile=etc/nova.conf project create admin admin
