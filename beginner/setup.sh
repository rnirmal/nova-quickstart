#!/bin/bash
# Setup script to install the required packages and update the configuration
# where needed to have a full running nova installation

NOVA_CONF="/etc/nova/nova.conf"
GLANCE_CONF="/etc/glance/glance.conf"

# Install the base required packages
sudo apt-get install -y python-software-properties

# Add the Nova Release ppa to get the latest release packages
sudo add-apt-repository ppa:nova-core/release
sudo apt-get update

# Install the messaging server - RabbitMQ
sudo apt-get install -y rabbitmq-server

# Install some python dependencies
sudo apt-get install -y python-greenlet python-mysqldb
sudo easy_install virtualenv

# Install the common nova code, update some of the configuration
sudo apt-get install -y nova-common nova-doc python-nova
sudo cp $NOVA_CONF $NOVA_CONF.orig

echo "
# Settings beyond default 
# Nova Database
--sql_connection=mysql://nova:nova@localhost/nova

# Image Service
--image_service=nova.image.glance.GlanceImageService

# Compute Service - Libvirt type qemu is easier on vms
--libvirt_type=qemu
" | sudo tee -a $NOVA_CONF

# Install Mysql to use as the Nova database and setup a default nova user
sudo -E DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
sudo mysql -u root -e "CREATE DATABASE nova;"
sudo mysql -u root -e "CREATE DATABASE glance;"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' WITH GRANT OPTION;"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON glance.* TO 'nova'@'%' WITH GRANT OPTION;"
sudo mysql -u root -e "SET PASSWORD FOR 'nova'@'%' = PASSWORD('nova');"
sudo service mysql restart

# Install and setup glance
sudo apt-get install -y python-glance python-glance-doc glance
sudo sed -i 's/sql_connection = sqlite:\/\/\/\/var\/lib\/glance\/glance.sqlite/sql_connection = mysql:\/\/nova:nova@localhost\/glance/g' $GLANCE_CONF
glance-manage db_sync
sudo service glance-api restart
sudo service glance-registry restart

# Initialize Nova
# Sync up the table definitions
nova-manage db sync
# Create a default set of fixed and floating ips
nova-manage network create 10.0.0.0/24 1 32
nova-manage floating create `hostname` 10.6.0.0/27
# Create a default admin user and a project and assign the admin user to it
nova-manage user admin admin admin admin
nova-manage project create admin admin

# Install and update iscsitarget
sudo apt-get install -y iscsitarget
sudo sed -i 's/false/true/g' /etc/default/iscsitarget
sudo service iscsitarget restart

# Give nove user full access to circumvent some bugs
echo "nova   ALL=NOPASSWD: ALL" | sudo tee -a /etc/sudoers

# Install the rest of the nova services
sudo apt-get install -y nova-api nova-scheduler nova-network nova-volume nova-compute

# Install a minimal linux distro (ttylinux)
mkdir ~/images
cd ~/images
wget -c http://images.ansolabs.com/tty.tgz
tar -zxf tty.tgz

# Upload the kernel, ramdisk and machine image to glance
glance-upload --type kernel aki-tty/image tty-kernel
glance-upload --type ramdisk ari-tty/image tty-ramdisk
glance-upload --type machine --kernel 1 --ramdisk 2 ami-tty/image tty

# Cleanup
rm -rf ~/images
