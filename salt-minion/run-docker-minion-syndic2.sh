#!/bin/bash
docker run -d -h minion_syndic2 -v /vagrant/salt-minion/syndic2.conf:/etc/salt/minion.d/master.conf ming_base_centos:centos6
