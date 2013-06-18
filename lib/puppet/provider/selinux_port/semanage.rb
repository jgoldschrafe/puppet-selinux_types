Puppet::Type.type(:selinux_port).provide(:semanage) do
  desc "Manage network port type definitions"

  commands :semanage => "semanage"

  mk_resource_methods

  Puppet::Util::Log.level = :debug
  Puppet::Util::Log.newdestination(:console)

  def self.instances
    types = []
    out = semanage('port', '-nl')
    out.split("\n").collect do |line|
      type, proto, ports = line.strip.squeeze(" ").split(" ",3)
      ports.gsub(/\s+/, "").split(',').each do |port|
        types << new(:name => "#{proto}/#{port}",
            :ensure => :present,
            :proto => proto,
            :port => port,
            :seltype => type
        )
      end
    end
    types
  end

  def self.prefetch(resources)
    types = instances
    resources.keys.each do |name|
      if provider = types.find{ |foo| foo.name == name}
        resources[name].provider = provider
      end
    end
  end
  
    def create
    Puppet.debug 'Running SELinux port create'
    fail "Semanage port #{resource[:name]} requires seltype parameter" unless resource[:seltype]
    Puppet.debug "Running checkport with /usr/sbin/semanage port --list | /bin/grep #{resource[:proto]} | /bin/grep #{resource[:port]}"
    checkport = `/usr/sbin/semanage port --list | /bin/grep #{resource[:proto]} | grep #{resource[:port]}`
    exit = $?
    Puppet.warning exit
    if exit == 0
      semanage "port", "-m", "-t", resource[:seltype], "-p", resource[:proto], resource[:port]
    else
      semanage "port", "-a", "-t", resource[:seltype], "-p", resource[:proto], resource[:port]
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    Puppet.debug 'Running SELinux port destroy'
    semanage "port", "-d", "-t", resource[:seltype], "-p", resource[:proto], resource[:port]
    @property_hash.clear
  end

  def exists?
    Puppet.debug 'Running SELinux port exists'
    @property_hash[:ensure] != :absent
  end

  def seltype=(value)
    Puppet.debug 'Running SELinux port modify'
    @property_hash[:seltype] = value
  end

end
