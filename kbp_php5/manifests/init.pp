# Author: Kumina bv <support@kumina.nl>

# Class: kbp_php5::curl
#
# Actions:
#  Install curl extensions for PHP5.
#
# Depends:
#  gen_puppet
#
class kbp_php5::curl {
  class { "gen_php5::curl":
    notify => Exec["reload-apache"];
  }
}
