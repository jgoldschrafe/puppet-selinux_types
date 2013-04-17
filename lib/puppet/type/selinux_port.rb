Puppet::Type.newtype(:selinux_port) do
  @doc = "Manage SELinux network port type definitions"

  ensurable

  def self.title_patterns
    [ [ /(([^\/]+)\/(.+))/m, [ [ :name ], [ :proto ], [ :port ] ] ] ]
  end

  newparam(:name) do
    desc "The name of the SELinux port to be managed."
  end

  newproperty(:seltype) do
    newvalues(/_port_t$/)
  end

  newparam(:proto, :namevar => true, :required => true) do
    newvalues(:tcp, :udp)
  end

  newparam(:port, :namevar => true, :required => true) do
    validate do |value|
      case value
        when /^\d+$/
          fail("Port value out of range. Should be between 1 and 65535") unless value.to_i.between?(1,65535)
        when /^(\d+)-(\d+)$/
          min, max = $1.to_i, $2.to_i
          fail("Wrong port range value. Should be between 1 and 65535 (eg. 8080-8085") unless (min < max && min.between?(1,65535) && max.between?(1,65535))
        else
          fail("Wrong port type. Should be either Integer or Range (eg. 80, 8080-8085")
      end
    end
  end
end
