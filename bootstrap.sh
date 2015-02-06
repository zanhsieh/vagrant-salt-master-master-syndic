#!/bin/bash

rpm -ivh /vagrant/epel-release-6-8.noarch.rpm
sed -i "s/mirrorlist=https/mirrorlist=http/" /etc/yum.repos.d/epel.repo
yum -y --enablerepo=epel update

YUM_PKGS="docker-io python-pip"
PIP_PKGS="docker-py==0.5.0"

if [ ! -f "/var/docker_setup" ]; then
  echo "Install docker"
  yum -y --enablerepo=epel-testing install $YUM_PKGS
  pip install $PIP_PKGS
  chkconfig docker on
  service docker start
  touch /var/docker_setup
fi
