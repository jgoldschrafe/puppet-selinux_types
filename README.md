Usage
=====
These types only require that `/usr/sbin/semanage` be installed.

Types
=====

selinux_fcontext
----------------

Creates, deletes, and modifies the SELinux file context rules database. Note
that it will not automatically initiate a filesystem relabel after it
completes, but you can of course have your `selinux_fcontext` resources
refresh an `exec` to handle that if you want that behavior.

Example:

```puppet
selinux_fcontext { '/usr/lib(64)?/nagios/plugins/check_disk':
  ensure   => 'present',
  selrange => 's0.c1023',
  seltype  => 'nagios_unconfined_plugin_exec_t',
  seluser  => 'root',
}
```

selinux_port
----------------

Creates, deletes, and modifies the SELinux network port type definitions. It accepts proto tcp/udp and port (range) between 1-65535.

Example:

```puppet
selinux_port { 'tcp/8080-8085':
  seltype => 'http_port_t',
}

selinux_port { 'udp/53':
  seltype => 'dns_port_t',
}
```

