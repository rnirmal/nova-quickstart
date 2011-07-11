Openstack Nova Beginner Quickstart (Cactus Release)
===================================================

1. Overview
2. Download
3. Setup
4. Reset

Overview
--------
This Quickstart helps you get started playing with OpenStack Nova in a few simple steps, with the Cactus release pre-packaged.
The image has all of the required components installed along with the OpenStack Dashboard.

Download
--------
Virtual Box sandbox image - Ubuntu 11.04 with Cactus Release and Openstack Dashboard

- [nova-sandbox-cactus.ova](http://c650070.r70.cf2.rackcdn.com/nova-sandbox-cactus.ova)

Setup
-----
- Download [nova-sandbox-cactus.ova](http://c650070.r70.cf2.rackcdn.com/nova-sandbox-cactus.ova)
- Install [Virtual Box](http://www.virtualbox.org)
- Start Virtual Box then,

        File -> Import Appliance -> Choose the downloaded .ova file

- Configure Virtual Box to use Bridged networking.

        Settings -> Network -> Adapter 1 -> Change NAT to Bridged Adapter

- If you want to use NAT, follow these instructions to be able to ssh to the VM [http://mydebian.blogdns.org/?p=148](http://mydebian.blogdns.org/?p=148)
- Start the nova-sandbox-cactus VM
- Login using _"nova"_ and password _"nova"_
- Get the IP address for _eth0_ if you want to ssh to the VM

        ifconfig | more

- For the first run update the scripts within nova-quickstart if you need to use any of it.

        cd /home/nova/nova-quickstart
        git pull

- Running OpenStack Dashboard

        /home/nova/run_dashboard

- All the other required nova services are started on boot.
 - nova-api
 - nova-compute
 - nova-network
 - nova-scheduler
 - nova-volume
 - glance-api
 - glance-registry
- Access the OpenStack dashboard at http://x.x.x.x:8000 Login using _"admin"_ password _"admin"_. Use the _eth0_ ip.


Reset
-----
Nova has some default quota limits set, which can be easily hit sometimes, so if you encounter any errors regarding quota just run the reset script. This will reset the Nova database entries and restart the services. Make sure you have all the instances deleted before running the script.

    $ /home/nova/nova-quickstart/beginner/reset.sh

