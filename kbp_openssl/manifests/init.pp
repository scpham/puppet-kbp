# Author: Kumina bv <support@kumina.nl>

# Class: kbp_openssl
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_openssl::common {
  include gen_openssl::common

  if $lsbmajdistrelease < 6 {
    gen_apt::preference {
      ["libssl0.9.8","openssl"]:
        version => "0.9.8g-15+lenny15";
    }
  }
  else {
    gen_apt::preference {
      ["libssl0.9.8","openssl"]:
        version => "0.9.8o-4squeeze5";
    }
  }
}
