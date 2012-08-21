# Author: Kumina bv <support@kumina.nl>

# This class is for system timekeeping with ntpd (or openntpd on lenny)
# Class: kbp_time
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_time {
  if $lsbdistmajrelease == '5' { # This is lenny
    include openntpd::common
  } elsif $lsbdistmajrelease == '6' { # This is squeeze or newer
    include ntp
    include kbp_trending::ntpd
  }
}
