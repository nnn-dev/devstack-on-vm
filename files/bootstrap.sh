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

set -e
DEBIAN_FRONTEND=noninteractive apt-get -qqy install software-properties-common
DEBIAN_FRONTEND=noninteractive apt-add-repository ppa:ansible/ansible
DEBIAN_FRONTEND=noninteractive apt-get -qqy update
DEBIAN_FRONTEND=noninteractive apt-get -qqy install ansible
ansible-galaxy --force install kamaln7.swapfile
if [ -d /opt/stack/devstack ]; then
su - $USERN -c /bin/bash <<EOF
if [ ! ~/.ssh/id_rsa.pub ]; then
 ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
fi
cd /opt/stack/devstack
(screen -ls | grep stack) && ./unstack.sh || :
killall -q glance-registry || :
EOF
fi
ansible-playbook -v ${DIRNAME}/install.yaml
chown -R $USERN /opt/stack/.
su - $USERN -c /bin/bash <<EOF
cd /opt/stack/devstack
[ -f /opt/stack/logs/error.log ] && rm /opt/stack/logs/error.log || :
./stack.sh
[ -f /opt/stack/logs/error.log ] && exit 133 || :
if [ -n "$3" ]; then
 bash /opt/stack/launchredstack.sh $3
fi
source /opt/stack/devstack/openrc admin
nova keypair-add test > /home/vagrant/test.pem
chmod 600 /home/vagrant/test.pem
EOF
cat <<EOF

 #####    ####   #    #  ######
 #    #  #    #  ##   #  #
 #    #  #    #  # #  #  #####
 #    #  #    #  #  # #  #
 #    #  #    #  #   ##  #
 #####    ####   #    #  ######

EOF