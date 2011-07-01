# Author: Kumina bv <support@kumina.nl>

# Class: kbp_cassandra::client
#
# Parameters:
#	customtag
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
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
#	java_monitoring
#		Undocumented
#	contact_groups
#		Undocumented
#	sms
#		Undocumented
#	customtag
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_cassandra::server($customtag="cassandra_${environment}", $java_monitoring=false, $contact_groups=false, $sms=true) {
	include kbp_monitoring::cassandra

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
			contact_groups => $contact_groups ? {
				false   => undef,
				default => $contact_groups,
			},
			sms            => $sms;
		}
	}
}
