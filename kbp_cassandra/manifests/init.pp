# Author: Kumina bv <support@kumina.nl>

# Class: kbp_cassandra::client
#
# Parameters:
#  customtag
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_cassandra::client($customtag="cassandra_${environment}",$ferm_saddr=$external_ipaddress) {
  kbp_ferm::rule { "Cassandra connections from ${fqdn}":
    exported => true,
    saddr    => $ferm_saddr,
    proto    => "tcp",
    dport    => 9160,
    action   => "ACCEPT",
    ferm_tag => $customtag;
  }
}

# Class: kbp_cassandra::server
#
# Parameters:
#  java_monitoring
#    Undocumented
#  servicegroups
#    Undocumented
#  sms
#    Undocumented
#  customtag
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  kbp_icinga::cassandra
#  gen_cassandra
#  gen_puppet
#
class kbp_cassandra::server($branch="07x", $customtag="cassandra_${environment}", $java_monitoring=false, $servicegroups=false, $sms=true, $use_ipaddress=$external_ipaddress) {
  include kbp_icinga::cassandra
  class { "gen_cassandra":
    branch => $branch;
  }

  # Make sure we use the Sun Java package
  Kpackage <| title == "cassandra" |> {
    require => Package["sun-java6-jdk"],
  }

  kbp_ferm::rule { "Internal Cassandra connections from ${fqdn}":
    exported => true,
    saddr    => $use_ipaddress,
    proto    => "tcp",
    dport    => 7000,
    action   => "ACCEPT",
    ferm_tag => $customtag;
  }

  Kbp_ferm::Rule <<| tag == $customtag |>>
  Gen_ferm::Rule <<| tag == "cassandra_monitoring" |>>

  if $java_monitoring {
    kbp_icinga::java { "cassandra_8080":
      servicegroups  => $servicegroups ? {
        false   => undef,
        default => $servicegroups,
      },
      sms            => $sms;
    }
  }
}
