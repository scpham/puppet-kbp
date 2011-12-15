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
class kbp_cassandra::client($customtag="cassandra_${environment}") {
  @@gen_ferm::rule { "Cassandra connections from ${fqdn}":
    saddr  => $fqdn,
    proto  => "tcp",
    dport  => 9160,
    action => "ACCEPT",
    tag    => $customtag;
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
#  kbp_monitoring::cassandra
#  gen_cassandra
#  gen_puppet
#
class kbp_cassandra::server($branch="07x", $customtag="cassandra_${environment}", $java_monitoring=false, $servicegroups=false, $sms=true) {
  include kbp_monitoring::cassandra
  class { "gen_cassandra":
    branch => $branch;
  }

  # Make sure we use the Sun Java package
  Kpackage <| title == "cassandra" |> {
    require => Package["sun-java6-jdk"],
  }

  @@gen_ferm::rule { "Internal Cassandra connections from ${fqdn}":
    saddr  => $fqdn,
    proto  => "tcp",
    dport  => 7000,
    action => "ACCEPT",
    tag    => $customtag;
  }

  Gen_ferm::Rule <<| tag == $customtag |>>
  Gen_ferm::Rule <<| tag == "cassandra_monitoring" |>>

  if $java_monitoring {
    kbp_monitoring::java { "cassandra_8080":
      servicegroups  => $servicegroups ? {
        false   => undef,
        default => $servicegroups,
      },
      sms            => $sms;
    }
  }
}
