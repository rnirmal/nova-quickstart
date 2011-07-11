Openstack Nova Advanced Quickstart (trunk - Diablo release)
===========================================================

1. Overview
2. Download
3. Setup

Overview
------------

Download
--------
Virtual Box Base image. - Ubuntu 11.04 with a physical volume and a default "nova-volumes" volume group.

- [nova-sandbox-base.ova](http://c650070.r70.cf2.rackcdn.com/nova-sandbox-base.ova)

Setup
-----

#### Setup logical volumes
    sudo lvremove -f nova-volumes
    sudo pvcreate -ff -y /dev/sda5
    sudo vgcreate nova-volumes /dev/sda5
