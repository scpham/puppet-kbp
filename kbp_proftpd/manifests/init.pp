# Author: Kumina bv <support@kumina.nl>

# Class: kbp_proftpd
#
# Actions:
#  Setup ProFTPd the way we like it.
#
# Depends:
#  gen_proftpd
#  gen_puppet
#
class kbp_proftpd {
  include gen_proftpd
}

# Class: kbp_proftpd::mysql
#
# Actions:
#  Setup MySQL authentication for ProFTPd.
#
# Depends:
#  kbp_proftpd
#  gen_puppet
#
class kbp_proftpd::mysql {
  include kbp_proftpd
  include gen_proftpd::mysql
}
