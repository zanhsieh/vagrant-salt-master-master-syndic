#!/bin/bash

if [ ! `grep -q '4505\|4506' /etc/sysconfig/iptables` ]; then
  echo "Open port 4505, 4506"
  sed -i 's|--dport 22 -j ACCEPT|--dport 22 -j ACCEPT\n-A INPUT -p tcp -m state --state NEW -m tcp --dport 4505 -j ACCEPT\n-A INPUT -p tcp -m state --state NEW -m tcp --dport 4506 -j ACCEPT\n|' /etc/sysconfig/iptables
  service iptables restart
  service iptables save
fi

if [ ! -f "/var/salt_syndic_setup" ]; then
  echo "Install salt-syndic"
  yum -y --enablerepo=epel install salt-master salt-syndic
  chkconfig salt-master on && chkconfig salt-syndic on
  sed -i 's|^#syndic_master: masterofmaster$|#syndic_master: masterofmaster\nsyndic_master: 10.0.0.11|' /etc/salt/master
  service salt-master start && service salt-syndic start
  #sed -i 's|^other_args=$|other_args="--insecure-registry master:5000"|' /etc/sysconfig/docker
  #service docker restart
  touch /var/salt_syndic_setup
fi

echo "Check host resolution to /etc/hosts"
if [ ! `grep -q 10.0.0.11 /etc/hosts` ]; then
  echo "192.168.40.11  master" >> /etc/hosts
fi

if [ ! `grep -q 10.0.0.12 /etc/hosts` ]; then
  echo "192.168.40.12  syndic1" >> /etc/hosts
fi

if [ ! `grep -q 10.0.0.13 /etc/hosts` ]; then
  echo "192.168.40.13  syndic2" >> /etc/hosts
fi

