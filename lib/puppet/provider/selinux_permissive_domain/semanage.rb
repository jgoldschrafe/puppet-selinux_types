Puppet::Type.type(:selinux_permissive_domain).provide(:semanage) do
  desc "Manage processes type enforcement mode"

  commands :semanage => "semanage"

  mk_resource_methods

  def self.instances
    domains = []
    types = semanage('permissive', '-nl')
    types.split("\n").collect do |t|
      domains << new(
        :name => t.strip,
        :ensure => :present
      )
    end
    domains 
  end

  def self.prefetch(resources)
    domains = instances
    resources.keys.each do |name|
      if provider = domains.find{ |t| t.name == name}
        resources[name].provider = provider
      end
    end
  end

  def create
    semanage "permissive", "-a", resource[:name]
    @property_hash[:ensure] = :present
  end

  def destroy
    semanage "permissive", "-d", resource[:name]
    @property_hash.clear
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
