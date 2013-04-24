Puppet::Type.newtype(:selinux_permissive_domain) do
  @doc = "Manage processes type enforcement mode"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Type to be changed to a permissive domain"
    newvalues(/_t$/)
  end

end
