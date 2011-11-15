begin
  require 'libvirt'

  uri = "qemu:///system"

  Facter.add("running_guests") {
    setcode do
      connection = Libvirt::open(uri)
      domains = connection.list_domains.collect {|did| connection.lookup_domain_by_id(did).name}
      connection.close
      domains.join(',')
    end
  }
rescue LoadError
end
