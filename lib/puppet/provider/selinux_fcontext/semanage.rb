Puppet::Type.type(:selinux_fcontext).provide(:semanage) do
  desc "Manage SELinux file contexts using semanage"

  commands :semanage => '/usr/sbin/semanage'

  mk_resource_methods

  @filetype_arg_map = {
    ''                 => '',
    'all files'        => '',
    '--'               => '--',
    'regular file'     => '--',
    '-d'               => '-d',
    'directory'        => '-d',
    '-c'               => '-c',
    'character device' => '-c',
    '-b'               => '-b',
    'block device'     => '-b',
    '-s'               => '-s',
    'socket'           => '-s',
    '-l'               => '-l',
    'symbolic link'    => '-l',
    '-p'               => '-p',
    'named pipe'       => '-p',
  }

  def self.prefetch(resources)
    found = {}

    execpipe("#{command(:semanage)} fcontext -lC") do |out|
      lines = out.readlines[2..-1] || []
      lines.each do |line|
        args = line.split(/\s+/)
        filespec = args[0]
        filetype = args.length == 4 ? args[1..2].join(' ') : args[1]
        context = args[-1]
        seluser, selrole, seltype, selrange = context.split(':')
        found[filespec] = { :ensure => :present, :filetype => filetype,
                            :selrange => selrange, :seltype => seltype,
                            :seluser => seluser }
      end
    end

    resources.each do |name, resource|
      if found.has_key?(name)
        resource.provider = new(found[name])
      else
        resource.provider = new(:ensure => :absent)
      end
    end
  end

  def create
    @flush_action = :create
  end

  def destroy
    @flush_action = :destroy
  end

  def exists?
    self.ensure != :absent
  end

  def flush
    case @flush_action
    when :create
      do_create
    when :destroy
      do_destroy
    else
      do_update
    end
  end

  private
    def do_create
      semanage 'fcontext', '-a', map_args, name
      self.ensure = :present
    end

    def do_destroy
      semanage 'fcontext', '-d', name
      self.ensure = :absent
    end

    def do_update
      semanage 'fcontext', '-m', map_args, name
    end

    def map_args
      optargs = []
      optargs << '-f' << @filetype_arg_map[resource[:filetype]] if resource[:filetype]
      optargs << '-r' << resource[:selrange] if resource[:selrange]
      optargs << '-t' << resource[:seltype] if resource[:seltype]
      optargs << '-s' << resource[:seluser] if resource[:seluser]
      return optargs
    end
end
