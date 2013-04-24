# Make sure you have semanage command available
# sudo puppet apply --noop --modulepath='..' tests/selinux_port.pp

selinux_port {'udp/53':
  seltype => 'dns_port_t'
}

selinux_port {'tcp/8080-8085':
  seltype => 'http_port_t'
}

resources {'selinux_port':
	purge => false,
}
