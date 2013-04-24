# Make sure you have semanage command available
# sudo puppet apply --noop --modulepath='..' tests/selinux_permissive_domain.pp

selinux_permissive_domain {'httpd_t':
  ensure => 'present',
}

selinux_permissive_domain {'condor_schedd_t':
  ensure => 'absent'
}

resources {'selinux_permissive_domain':
	purge => false,
}
