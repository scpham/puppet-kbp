if File.exists?('/srv/glassfish/domains')
  autostart_domains = []
  Dir.glob('/srv/glassfish/domains/*').each do |domain|
    if File.exists?("#{domain}/autostart")
      autostart_domains << File.basename(domain)
    end
  end
  Facter.add('glassfish_autostart_domains') { setcode { autostart_domains.join(',') } } if ! autostart_domains.empty?
end
