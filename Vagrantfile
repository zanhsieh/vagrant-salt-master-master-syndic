# -*- mode: ruby -*-
# vi: set ft=ruby :

$IPs = {
  "min-syn1"       => "10.0.10.22",
  "syndic1"        => "10.0.10.21",
  "min-syn2"       => "10.0.10.32",
  "syndic2"        => "10.0.10.31",
  "master"         => "10.0.10.11",
}

$ports_master = [4505,4506,5000]
$ports_syndic = [4505,4506]

def gen_roster(ips={}, exclude=[])
  return ips.map {|k,v|
  if not exclude.include? (k)
<<-INNER
#{k}:
  host: #{v}
  user: vagrant
  passwd: vagrant
  sudo: True
INNER
  end
  }.join
end

def host_check(ips={})
  return ips.map {|k,v|<<-INNER
if [ ! `grep -q #{v} /etc/hosts` ]; then
  echo '#{v} #{k}' | sudo tee -a /etc/hosts
fi
  INNER
  }.join
end

def firewall_setup(ports=[])
  case ports.size
  when 0
    return
  else
    return <<-INNER
if [ ! `grep -q '#{ports.join('\|')}' /etc/sysconfig/iptables` ]; then
  echo "Open port #{ports.join(',')}"
  LN=$(iptables -L --line-numbers | grep REJECT | cut -d ' ' -f1 | head -n 1)
  iptables -N allow_services
  iptables -I INPUT $LN -j allow_services
  iptables -A allow_services -p tcp --match multiport --dports #{ports.join(',')} -j ACCEPT
  service iptables save
  service iptables restart
fi
    INNER
  end
end

def locale_setup
  return <<-LOCALESETUP
rm -f /etc/sysconfig/clock
echo "ZONE=\"Asia/Hong_Kong\"" > /etc/sysconfig/clock
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Hong_Kong /etc/localtime
[ -z "$LC_ALL" ] && echo "export LC_ALL=$LANG" >> /etc/profile.d/lang.sh
  LOCALESETUP
end

def master_setup(m)
  return <<-MASTERSETUP
#{firewall_setup($ports_master)}
if [ ! -f "/var/salt_master_setup" ]; then
echo "Install salt-master"
yum -y install epel-release
yum -y --enablerepo=epel install docker-io python-pip salt-master salt-ssh
pip install docker-py==0.5.0
service docker start
chkconfig salt-master on
[ ! -d /etc/salt/master.d ] && mkdir -p /etc/salt/master.d
tee /etc/salt/master.d/master.conf <<-EOF
interface: #{$IPs[m]}
order_masters: True
EOF
tee /etc/salt/roster <<-EOF
#{gen_roster($IPs,[m])}
EOF
ln -s /vagrant/srv/pillar /srv/pillar
ln -s /vagrant/srv/salt /srv/salt
service salt-master start
echo 'Y' | salt-key -A
touch /var/salt_master_setup
fi
  MASTERSETUP
end

def syndic_setup(m)
  return <<-SYNDICSETUP
#{firewall_setup($ports_syndic)}
if [ ! -f "/var/salt_syndic_setup" ]; then
echo "Install salt-syndic"
yum -y install epel-release
yum -y --enablerepo=epel install docker-io python-pip salt-master salt-syndic salt-minion
pip install docker-py==0.5.0
service docker start
chkconfig salt-master on
chkconfig salt-syndic on
[ ! -d /etc/salt/master.d ] && mkdir -p /etc/salt/master.d
echo 'syndic_master: master' > /etc/salt/master.d/master.conf
[ ! -d /etc/salt/minion.d ] && mkdir -p /etc/salt/minion.d
echo 'master: #{m}' > /etc/salt/minion.d/master.conf
echo '#{m}_internal_minion' > /etc/salt/minion_id
service salt-master start && service salt-syndic start && service salt-minion start
echo 'Y' | salt-key -A
touch /var/salt_syndic_setup
fi
  SYNDICSETUP
end


def minion_setup(m)
  which_master = ""
  case m
  when "min-syn1"
    which_master = "syndic1"
  when "min-syn2"
    which_master = "syndic2"    
  else
    which_master = "master"
  end
  return <<-MINIONSETUP
if [ ! -f "/var/salt_minion_setup" ]; then
echo "Install salt-minion"
yum -y install epel-release
yum -y --enablerepo=epel install salt-minion
chkconfig salt-minion on
[ ! -d /etc/salt/minion.d ] && mkdir -p /etc/salt/minion.d
echo 'master: #{which_master}' > /etc/salt/minion.d/master.conf
service salt-minion start
touch /var/salt_minion_setup
fi
  MINIONSETUP
end


Vagrant.configure(2) do |config|
  config.vm.box = "centos66"
  config.vm.box_check_update = false
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = "box"
    config.cache.synced_folder_opts = {
      type: "nfs",
      mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
    }
  end
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end
  config.vm.synced_folder '.', '/vagrant', nfs: true

  $IPs.map do |k,v|
    config.vm.define "#{k}" do |m|
      m.vm.hostname = "#{k}"
      m.vm.network "private_network", ip: "#{v}"
      m.vm.provision "shell", inline:<<-SHELL
      #{host_check($IPs)}
      SHELL
      m.vm.provision "shell", inline:<<-SHELL
      #{locale_setup}
      SHELL
      m.vm.provision "shell", inline:<<-SHELL
      #{case k
        when "master"
          master_setup(k)
        when "syndic1", "syndic2"
          syndic_setup(k)
        else
          minion_setup(k)
        end
      }      
      SHELL
    end
  end
end
