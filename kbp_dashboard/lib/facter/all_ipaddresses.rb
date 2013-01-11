fact = ''
Facter.value(:interfaces).split(',').each do |interface|
  fact = fact + interface + '|'
  %x{/bin/ip address show #{interface}}.scan(/^    inet6? ([^ ]*)/).flatten.each do |address|
    fact = fact + address + ','
  end
  fact.chomp!(',')
  fact = fact + ';'
end
Facter.add(:all_ipaddress) { setcode { fact } }
