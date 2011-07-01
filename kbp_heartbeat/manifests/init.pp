# Author: Kumina bv <support@kumina.nl>

# Class: kbp_heartbeat
#
# Parameters:
#	otherhost
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_heartbeat($otherhost) {
	include gen_heartbeat
	include kbp_monitoring::heartbeat

	# The ha.cf file for heartbeat defines the nodes, nics and ip addresses used for inter-node communication. Here we set some defaults options for the cluster.
	# The only needed option is nodes in the following format:
	# kbp_heartbeat::ha_cf {
	# nodes => { "node1" => {"NIC" => "IPADDRESS"}, "node2" => {"NIC" => "IPADDRESS"} } ;
	# }
	define ha_cf ($autojoin="none", $warntime=5, $deadtime=15,
		$initdead=60, $keepalive=2, $crm="respawn", nodes=false ) {
		gen_heartbeat::ha_cf { "${name}":
			autojoin  => $autojoin,
			warntime  => $warntime,
			deadtime  => $deadtime,
			initdead  => $initdead,
			keepalive => $keepalive,
			crm       => $crm,
			nodes     => $nodes;
		}
	}

	gen_ferm::rule { "Heartbeat connections from ${otherhost}":
		saddr  => $otherhost,
		proto  => "udp",
		dport  => 694,
		action => "ACCEPT";
	}
}
