# vagrant-salt-master-master-syndic

This repo provide 1 grand master (Virtualbox VM) + 2 syndic master VMs + minion within (Vitualbox VM
), 2 minions (Virtualbox VM), plus docker salt-minion template to build minions under to experience GM-SyndicM-M infrastructure.

# note

1. Since syndic master does not respond to test.ping, install minion within should be required for troubleshooting & monitoring purpose. By default CentOS 6 installation would cause conflict minion and syndic on its hostname, therefore pre-seeding the minion id should do the trick.
2. Calling state.highstate from grand master will fail by default, since syndic master has its own file_root and won't sync automatically with grand master, whereas the minions under syndic master only requests files from syndic master. GitFS, incrond+rsync, a dedicated minion handling sync would be 3 solutions.
