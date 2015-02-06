#!/bin/bash
docker run -d -h minion_syndic1 -v /vagrant/salt-minion/syndic1.conf:/etc/salt/minion.d/master.conf m800_base_centos:centos6
