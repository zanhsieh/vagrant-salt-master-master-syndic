FROM centos:centos6
MAINTAINER Ming Hsieh zanhsieh@gmail.com

# Do Salt install stuff and squeeze in a master.conf snippet that tells the minion
# to contact the master specified.

#RUN rpm -Uvh http://ftp.cuhk.edu.hk/pub/Linux/fedora-epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN rpm -Uvh  http://ftp.cuhk.edu.hk/pub/linux/fedora-epel/6/i386/epel-release-6-8.noarch.rpm

RUN yum -y --enablerepo=epel-testing install salt-minion openssh-server cronie cronie-anacron rsyslog wget man && yum -y update && yum clean all
ADD ./m800.repo /etc/yum.repos.d/
ADD ./M800-epel.repo /etc/yum.repos.d/
ADD ./epel.repo /etc/yum.repos.d/
ADD ./epel-testing.repo /etc/yum.repos.d/

RUN [ ! -d /etc/salt/minion.d ] && mkdir -p /etc/salt/minion.d
ADD ./master.conf /etc/salt/minion.d/master.conf

RUN chkconfig sshd on
RUN chkconfig rsyslog on
RUN chkconfig salt-minion on
RUN rm -f /etc/init/start-ttys.conf
RUN rm -f /etc/init/tty.conf
RUN echo "root:12345678"|chpasswd
RUN sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd

# This is important because the Docker container will exit whenever
# the CMD process exits.

CMD /sbin/init

