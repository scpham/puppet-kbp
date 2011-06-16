if FileTest.exists?("/usr/bin/lspci")

  def add_fact(fact, code)
    Facter.add(fact) { setcode { code } }
  end

  # Create a hash of ALL PCI devices, the key is the PCI slot ID.
  # { SLOT_ID => { ATTRIBUTE => VALUE }, ... }
  slot=""
  # after the following loop, devices will contain ALL PCI devices and the info returned from lspci
  devices = {}
  %x{/usr/bin/lspci -v -mm -k}.each_line do |line|
    if not line =~ /^$/ # We don't need to parse empty lines
      splitted = line.split(/\t/)
      # lspci has a nice syntax:
      # ATTRIBUTE:\tVALUE
      # We use this to fill our hash
      if splitted[0] =~ /^Slot:$/
        slot=splitted[1].chomp
        devices[slot] = {}
      else
        # The chop is needed to strip the ':' from the string
        devices[slot][splitted[0].chop] = splitted[1].chomp
      end
    end
  end

  raid_counter = 0
  devices.each_key do |a|
    if devices[a].fetch("Class") =~ /^RAID/
      add_fact("raidcontroller#{raid_counter}_vendor", "#{devices[a].fetch('Vendor')}")
      add_fact("raidcontroller#{raid_counter}_driver", "#{devices[a].fetch('Driver')}")
      raid_counter += 1
    end
  end
end
