# Author: Kumina bv <support@kumina.nl>

# Class: kbp_acpi
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_acpi {
  include gen_acpi

  if $lsbmajdistrelease < 6 {
    gen_apt::preference {
      ["acpid"]:
        version => "1.0.8-1lenny4";
    }
  }
  else {
    gen_apt::preference {
      ["acpid"]:
        version => "1:2.0.7-1squeeze3";
    }
  }

}
