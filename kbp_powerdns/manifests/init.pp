# Author: Kumina bv <support@kumina.nl>

# Class: kbp_powerdns::master
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_powerdns::master {
  include powerdns::master

  Gen_ferm::Rule <<| tag == "bind_${environment}" |>>

  Gen_ferm::Rule <<| tag == "poweradmin_${environment}" |>>

  Gen_ferm::Rule <<| tag == "dns_monitoring" |>>
}
