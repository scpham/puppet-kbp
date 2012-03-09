# Author: Kumina bv <support@kumina.nl>

# Class: kbp_arpwatch
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_arpwatch {
  include arpwatch

  File <| title == "/etc/default/arpwatch" |> {
    content => template("kbp_arpwatch/arpwatch"),
  }

  kbp_icinga::service { "arpwatch":
    service_description => "Arpwatch daemon",
    check_command       => "check_arpwatch",
    nrpe                => true;
  }
}
