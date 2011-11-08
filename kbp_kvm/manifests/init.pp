# Author: Kumina bv <support@kumina.nl>

# Class: kbp_kvm
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_kvm {
  include gen_kvm

  if $lsbmajdistrelease < 6 {
    gen_apt::preference { "qemu-kvm":; }
  }

  # Enable KSM
  exec { "/bin/echo 1 > /sys/kernel/mm/ksm/run":
    onlyif => "/usr/bin/test `cat /sys/kernel/mm/ksm/run` -eq 0",
  }

}
