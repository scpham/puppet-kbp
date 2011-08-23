# Author: Kumina bv <support@kumina.nl>

# Class: kbp_ferm
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_ferm {
	include kbp_ferm::offenders
	include gen_ferm

	Gen_ferm::Rule <<| tag == "general" |>>

	@gen_ferm::chain {
		["PREROUTING_v4","PREROUTING_v6"]:
			table => "nat";
		["POSTROUTING_v4","POSTROUTING_v6"]:
			table  => "nat",
			policy => "ACCEPT";
		["ACCOUNTING_v4","ACCOUNTING_v6"]:;
	}

	# Basic rules
	gen_ferm::rule {
		"Respond to ICMP packets_v4":
			proto    => "icmp",
			icmptype => "echo-request",
			action   => "ACCEPT";
		"Drop UDP packets":
			prio  => "a0",
			proto => "udp";
		"Nicely reject tcp packets":
			prio   => "a1",
			proto  => "tcp",
			action => "REJECT reject-with tcp-reset";
		"Reject everything else":
			prio   => "a2",
			action => "REJECT";
		"Drop UDP packets (forward)":
			prio  => "a0",
			proto => "udp",
			chain => "FORWARD";
		"Nicely reject tcp packets (forward)":
			prio   => "a1",
			proto  => "tcp",
			action => "REJECT reject-with tcp-reset",
			chain  => "FORWARD";
		"Reject everything else (forward)":
			prio   => "a2",
			action => "REJECT",
			chain  => "FORWARD";
		"Respond to ICMP packets (NDP)_v6":
			prio     => 00001,
			proto    => "icmpv6",
			icmptype => "(neighbour-solicitation neighbour-advertisement)",
			action   => "ACCEPT";
		"Respond to ICMP packets (diagnostic)_v6":
			proto    => "icmpv6",
			icmptype => "echo-request",
			action   => "ACCEPT";
	}
}

# Class: kbp_ferm::offenders
#
# Parameters:
#	None
#
# Actions:
#	Disable access from known bad IP addresses to all machines in our control.
#	Use with care.
#
# Depends:
#	kbp_ferm
#	gen_puppet
#
class kbp_ferm::offenders {
	# Please add a comment describing when the IP was added and what for.
	kbp_ferm::block {
		# 20110823 Ssh brute force attacks on IQNOMY for several days
		"219.111.16.42":;
		# 20110823 Ssh brute force attacks on IQNOMY
		"180.168.201.47":;
	}
}

# Define: kbp_ferm::block
#
# Parameters:
#	name
#		IP address to block completely
#
# Actions:
#	Drops all traffic from the IP address.
#
# Depends:
#	kbp_ferm
#	gen_puppet
#
define kbp_ferm::block {
	gen_ferm::rule {
		"Drop all traffic from ${name}.":
			saddr  => $name,
			action => "DROP";
		"Drop all forwarded traffic from ${name}.":
			saddr  => $name,
			chain  => "FORWARD",
			action => "DROP";
	}
}

# Define: kbp_ferm::forward
#
# Parameters:
#	proto
#		Undocumented
#	port
#		Undocumented
#	dest
#		Undocumented
#	dport
#		Undocumented
#	inc
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_ferm::forward($inc, $proto, $port, $dest, $dport) {
	gen_ferm::rule {
		"Accept all ${proto} traffic from ${inc} to ${dest}:${port}_v4":
			chain     => "FORWARD",
			interface => "eth1",
			saddr     => $inc,
			daddr     => $dest,
			proto     => $proto,
			dport     => $port,
			action    => "ACCEPT";
		"Forward all ${proto} traffic from ${inc} to ${port} to ${dest}:${dport}_v4":
			table  => "nat",
			chain  => "PREROUTING",
			daddr  => $inc,
			proto  => $proto,
			dport  => $port,
			action => "DNAT to \"${dest}:${dport}\"";
	}
}
