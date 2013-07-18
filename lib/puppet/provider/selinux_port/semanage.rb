Puppet::Type.type(:selinux_port).provide(:semanage) do
  desc "Manage network port type definitions"

  commands :semanage => "semanage"

  mk_resource_methods

  def self.instances
    types = []
    out = %x[#{command(:semanage)} port -nl]
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
    fail "Semanage port #{resource[:name]} requires seltype parameter" unless resource[:seltype]
    semanage "port", "-a", "-t", resource[:seltype], "-p", resource[:proto], resource[:port]
    @property_hash[:ensure] = :present
  end

  def destroy
    semanage "port", "-d", "-p", resource[:proto], resource[:port]
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def seltype=(value)
    semanage "port", "-m", "-t", value, "-p", resource[:proto], resource[:port]
    @property_hash[:seltype] = value
  end

end
