Openstack Nova Advanced Quickstart (trunk - Diablo release)
===========================================================

1. Overview
2. Download
3. Prerequisites
4. Running Keystone
5. Running Glance
6. Running Nova
7. Running Dashboard 

Overview
--------
This quickstart helps you get started with Nova in a few easy steps. I try to keep it updated with Nova trunk as possible. This is geared towards installing and running nova in a sandbox development environment, this setup does not consider anything else.
There are atleast a thousand ways in which Nova can be configured, this quickstart is going to walk you through one of them and making it as simple as possible. Its highly advised to use the provided Virtual Box image as the base to have a good shot at a working copy of Nova. You can build your own images but other distributions of Linux might require some different steps.

Download
--------
Virtual Box Base image - Ubuntu 11.04 with a physical volume and a default "nova-volumes" volume group.

- [nova-sandbox-base.ova](http://c650070.r70.cf2.rackcdn.com/nova-sandbox-base.ova)

Prerequisites
-------------
- Install [Virtual Box](http://www.virtualbox.org)
- Download [nova-sandbox-base](http://c650070.r70.cf2.rackcdn.com/nova-sandbox-base.ova)
- Start Virtual Box then,

        File -> Import Appliance -> Choose the downloaded .ova file

- Configure Virtual Box to use Bridged networking.

        Settings -> Network -> Adapter 1 -> Change NAT to Bridged Adapter
- Start the nova-sandbox-base VM
- Login using _"nova"_ and password _"nova"_

#### Install Git and Bzr
- OpenStack Nova code base is hosted on Launchpad and uses bzr as the version control.
- OpenStack Dashboard and this quickstart are on github and hence the requirement for git.

        $ sudo apt-get install git bzr

#### Checkout the code
- For the quickstart purposes we are going to keep all the code in `/home/nova` and all paths are relative to that
- Checkout Nova

        $ cd
        $ mkdir nova
        $ cd nova
        $ bzr init-repo .
        $ bzr clone lp:nova trunk

- Checkout Glance

        $ cd
        $ mkdir glance
        $ cd glance
        $ bzr init-repo .
        $ bzr clone lp:glance trunk

- Checkout Keystone

        $ cd
        $ git clone git://github.com/rackspace/keystone.git

- Checkout Dashboard

        $ cd
        $ git clone git://github.com/4P/openstack-dashboard.git

- Checkout the nova-quickstart

        $ cd
        $ git clone git://github.com/rnirmal/nova-quickstart.git

#### Install dependencies
- Below is a list of some of the dependencies along with an explanation 
- Install Python Software Properties

        $ sudo apt-get install python-software-properties

- Add nova trunk ppa repository to get latest updates to some of the required python tools

        $ sudo add-apt-repository ppa:nova-core/trunk
        $ sudo apt-get update

- Install Kvm and libvirt and other required dependencies, update and restart

        $ sudo apt-get install kvm libvirt-bin kpartx iptables ebtables vlan curl socat unzip
        $ sudo modprobe kvm
        $ sudo modprobe nbd
        $ sudo service libvirt-bin restart

- Install ISCSI software for volume management and enable iscsitarget

        $ sudo apt-get install lvm2 iscsitarget open-iscsi
        $ sudo sed -i 's/false/true/g' /etc/default/iscsitarget
        $ sudo service iscsitarget restart

- Install Rabbit MQ Server

        $ sudo apt-get install rabbitmq-server

- Install a whole bunch of required python libraries/tools

        $ sudo apt-get install python-mox python-ipy python-paste python-migrate python-gflags python-greenlet python-novaclient
        $ sudo apt-get install python-libvirt python-libxml2 python-routes python-netaddr python-pastedeploy
        $ sudo apt-get install python-eventlet python-cheetah python-carrot python-tempita python-sqlalchemy
        $ sudo apt-get install python-suds python-lockfile python-m2crypto git-core python-dev python-argparse
        $ sudo apt-get install python-wsgiref python-lxml python-pastescript python-webob python-twisted python-boto

- Install Sqlite

        $ sudo apt-get install sqlite3 python-pysqlite2

- Install Mysql. Set a root password when prompted for it. For docs purposes its $ROOTPASS

        $ sudo apt-get install mysql-server python-mysqldb
        $ mysql -u root -p$ROOTPASS -e "CREATE DATABASE nova;"
        $ mysql -u root -p$ROOTPASS -e "CREATE DATABASE glance;"
        $ mysql -u root -p$ROOTPASS -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' WITH GRANT OPTION;"
        $ mysql -u root -p$ROOTPASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'nova'@'%' WITH GRANT OPTION;"
        $ mysql -u root -p$ROOTPASS -e "SET PASSWORD FOR 'nova'@'%' = PASSWORD('nova');"

- Download a sample machine image to use with Nova

        $ cd
        $ mkdir images
        $ cd images
        $ wget -c http://images.ansolabs.com/tty.tgz
        $ tar -zxf tty.tgz


Running Keystone
----------------

Running Glance
--------------
Glance provides services for discovering, registering, and retrieving virtual machine images. Glance has a RESTful API that allows querying of VM image metadata as well as retrieval of the actual image.

- Lets start with installing glance from source so nova can use the client code, wihtout having to setup extra paths.

        $ cd /home/nova/glance/trunk
        $ sudo python setup.py install

- Configure glance with some basic defaults. For this we will use a local filesystem to store the images and use mysql for the metadata.

        # Create a directory for local image store
        $ sudo mkdir -p /var/lib/glance/images
        $ sudo mkdir -p /var/log/glance

        # Update etc/glance-registry.conf
        sql_connection = mysql://nova:nova@localhost/glance

        # Setup the required tables
        $ sudo glance-manage --config-file=/home/nova/glance/trunk/etc/glance-registry.conf db_sync 

- Run Glance API and Glance Registry

        $ cd /home/nova/glance/trunk

        # Start API
        $ sudo bin/glance-api --config-file=etc/glance-api.conf &

        # Start Registry
        $ sudo bin/glance-registry --config-file=etc/glance-registry.conf &

- Upload images to glance

        $ bin/glance-upload --type kernel /home/nova/images/aki-tty/image tty-kernel
        $ bin/glance-upload --type ramdisk /home/nova/images/ari-tty/image tty-ramdisk
        $ bin/glance-upload --type machine --kernel 1 --ramdisk 2 /home/nova/images/ami-tty/image tty

- Lets list and make sure the images are there

        # List all images
        $ bin/glance index

        # List all images with details
        $ bin/glance details

        # List a image
        $ bin/glance show <id>


Running Nova
------------
Nova is a cloud computing fabric controller (the main part of an IaaS system).

- Lets apply a quick patch before we start. Some of this should be fixed soon, others may not make it.

        $ cd /home/nova/nova/trunk
        $ bzr patch /home/nova/nova-quickstart/advanced/nova.patch

- Initialize Nova

        # Create some required directories
        $ cd /home/nova/nova/trunk
        $ sudo mkdir -p /var/log/nova
        $ sudo mkdir -p /var/lock/nova
        $ sudo mkdir -p /var/lib/nova/instances

        # Copy the sample conf file
        $ cp /home/nova/nova-quickstart/advanced/nova.conf.sample etc/nova.conf

        # Setup the database tables
        $ sudo bin/nova-manage --flagfile=etc/nova.conf db sync

        # Create a default set of fixed and floating ips
        $ sudo bin/nova-manage --flagfile=etc/nova.conf network create private 10.0.0.0/24 1 32 0 0 0 0 br100 eth0
        $ sudo bin/nova-manage --flagfile=etc/nova.conf floating create 10.6.0.0/27

        # Create a default admin user and a project and assign the admin user to it
        $ sudo bin/nova-manage --flagfile=etc/nova.conf user admin admin admin admin
        $ sudo bin/nova-manage --flagfile=etc/nova.conf project create admin admin

        # Create a key pair to use for passwords login to created instances
        $ sudo bin/nova-manage --flagfile=etc/nova.conf key create admin mykey > mykey.pem
        $ chmod 600 mykey.pem

        # Give nova user sudo access without a password
        $ echo "nova   ALL=NOPASSWD: ALL" | sudo tee -a /etc/sudoers

#### Start all the Nova services

        # Nova API
        $ sudo bin/nova-api --flagfile=etc/nova.conf

        # Nova Scheduler
        $ sudo bin/nova-scheduler --flagfile=etc/nova.conf

        # Nova Network
        $ sudo bin/nova-network --flagfile=etc/nova.conf

        # Nova Compute
        $ sudo bin/nova-compute --flagfile=etc/nova.conf

        # Nova Volume
        $ sudo bin/nova-volume --flagfile=etc/nova.conf

#### Start and Stop with a script
- Start all the nova services and glance with this script

        $ cd /home/nova/nova-quickstart/advanced
        $ ./nova-start.sh

- Stop all the services

        # Cancel out of one of the screen windows and
        $ ./nova-stop.sh

### Create/list/delete instances using novacurl.sh
Using the sample `novacurl.sh` we are going to create, list and delete instances by running simple
bash fuctions with curl commands.

- Login and get and _auth_token_ using the _username_ and _apikey_

        $ cd /home/nova/nova-quickstart
        $ . novacurl.sh
        $ nova_login admin admin

- List available images

        $ list_images

- List available flavors

        $ list_flavors

- Create a erver

        $ create_server [name] [flavor id] [image id]

- List available servers

        $ list_servers

- Delete a server

        $ delete_server [id]


Running Dashboard
-----------------

