#!/bin/sh -x

if [ -n "$1" ]; then
 DIRNAME=$1
else
 DIRNAME=$(cd $(dirname $0); pwd -P)
fi

if [ -n "$2" ]; then
 USERN=$2
else
 USERN=$(id -un)
fi

set -x
DEBIAN_FRONTEND=noninteractive apt-get -qqy install software-properties-common
DEBIAN_FRONTEND=noninteractive apt-add-repository ppa:ansible/ansible
DEBIAN_FRONTEND=noninteractive apt-get -qqy update
DEBIAN_FRONTEND=noninteractive apt-get -qqy install ansible
ansible-galaxy install kamaln7.swapfile
if [ -d /opt/stack/devstack ]; then
su - $USERN -c /bin/bash <<EOF
if [ ! ~/.ssh/id_rsa.pub ]; then
 ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
fi
cd /opt/stack/devstack
(screen -ls | grep stack) && ./unstack.sh || :
EOF
fi
ansible-playbook -v ${DIRNAME}/install.yaml
chown -R $USERN /opt/stack/.
su - $USERN -c /bin/bash <<EOF
cd /opt/stack/devstack
./stack.sh
if [ -n "$3" ]; then
 cd /opt/stack/tiwork/trove-integration/scripts; HOSTALIASES=/etc/host.aliases ./redstack kick-start $3
fi
source /opt/stack/devstack/openrc admin
nova flavor-create m1.rd-smaller 8 768 3 1 --ephemeral 0 --swap 0 --is-public true
EOF