class kbp_ferm {
	include ferm::new

	ferm::new::rule {
		"Munin connections_v46":
			saddr  => "munin.kumina.nl",
			proto  => "tcp",
			dport  => "4949",
			action => "ACCEPT";
		"Puppet connections_v46":
			saddr  => "puppet.kumina.nl",
			proto  => "tcp",
			dport  => "8140",
			action => "ACCEPT";
	}

	# Basic rules
	ferm::new::rule {
		"Respond to ICMP packets_v4":
			proto    => "icmp",
			icmptype => "echo-request",
			action   => "ACCEPT";
		"SSH_v46":
			proto  => "tcp",
			dport  => "22",
			action => "ACCEPT";
		"Drop UDP packets_v46":
			prio  => "a0",
			proto => "udp";
		"Nicely reject tcp packets_v46":
			prio       => "a1",
			proto      => "tcp",
			action     => "REJECT",
			rejectwith => "tcp-reset";
		"Reject everything else_v46":
			prio   => "a2",
			action => "REJECT";
		"Drop UDP packets (forward)_v46":
			prio  => "a0",
			proto => "udp",
			chain => "FORWARD";
		"Nicely reject tcp packets (forward)_v46":
			prio       => "a1",
			proto      => "tcp",
			action     => "REJECT",
			rejectwith => "tcp-reset",
			chain      => "FORWARD";
		"Reject everything else (forward)_v46":
			prio   => "a2",
			action => "REJECT",
			chain  => "FORWARD";
		"Respond to ICMP packets (NDP)_v6":
			proto    => "icmpv6",
			icmptype => "(neighbour-solicitation neighbour-advertisement)",
			action   => "ACCEPT";
		"Respond to ICMP packets (diagnostic)_v6":
			proto    => "icmpv6",
			icmptype => "echo-request",
			action   => "ACCEPT";
	}
}
