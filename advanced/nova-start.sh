#!/usr/bin/env bash

if [ ! -f ~/.screenrc ]; then
    cat >~/.screenrc <<EOF
hardstatus on
hardstatus alwayslastline
hardstatus string "%{.bW}%-w%{.rW}%n %t%{-}%+w %=%{..G}%H %{..Y}%d/%m %c"

defscrollback 1024

vbell off
startup_message off
EOF
fi


NOVA_HOME=/home/nova/nova/trunk/
GLANCE_HOME=/home/nova/glance/trunk/

NL=`echo -ne '\015'`

function screen_it {
    screen -S nova -X screen -t $1
    screen -S nova -p $1 -X stuff "$2$NL"
}

CONFFILE="--flagfile=/home/nova/nova/trunk/etc/nova.conf"

screen -d -m -S nova -t nova
sleep 1

screen_it glance-reg "sudo $GLANCE_HOME/bin/glance-registry --config-file=/home/nova/glance/trunk/etc/glance-registry.conf --debug"
screen_it glance-api "sudo $GLANCE_HOME/bin/glance-api --config-file=/home/nova/glance/trunk/etc/glance-api.conf --debug"

screen_it api "sudo $NOVA_HOME/bin/nova-api $CONFFILE"
screen_it compute "sudo $NOVA_HOME/bin/nova-compute $CONFFILE"
screen_it network "sudo $NOVA_HOME/bin/nova-network $CONFFILE"
screen_it scheduler "sudo $NOVA_HOME/bin/nova-scheduler $CONFFILE"
screen_it volume "sudo $NOVA_HOME/bin/nova-volume $CONFFILE"
screen_it test ""
screen -S nova -x
