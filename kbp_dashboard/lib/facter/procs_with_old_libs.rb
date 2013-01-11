if File.exists?('/usr/lib/nagios/plugins/check_libs')
  o = %x{/usr/lib/nagios/plugins/check_libs}.scan((/ ([^ ]*) \([ \d,]+\)/)).flatten
  ['sh','cron','sleep'].each { |d| o.delete(d) }
  if o.length > 0
    Facter.add(:procs_with_old_libs) { setcode { o.join(',') } }
  else
    Facter.add(:procs_with_old_libs) { setcode { ' ' } }
  end
end
