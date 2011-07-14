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

        $ sudo apt-get install python-mox python-ipy python-paste python-migrate python-gflags python-greenlet
        $ sudo apt-get install python-libvirt python-libxml2 python-routes python-netaddr python-pastedeploy
        $ sudo apt-get install python-eventlet python-cheetah python-carrot python-tempita python-sqlalchemy
        $ sudo apt-get install python-suds python-lockfile python-m2crypto git-core python-dev python-argparse
        $ sudo apt-get install python-wsgiref python-lxml python-pastescript python-webob python-twisted

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

Running Nova
------------

Running Dashboard
-----------------

