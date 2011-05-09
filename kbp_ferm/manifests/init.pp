class kbp_ferm {
	include ferm::new

	Ferm::New::Rule <<| tag == 'ferm_general_rule' |>>

	@chain {
		["PREROUTING_v4","PREROUTING_v6"]:
			table => "nat";
		["POSTROUTING_v4","POSTROUTING_v6"]:
			table  => "nat",
			policy => "ACCEPT";
		["ACCOUNTING_v4","ACCOUNTING_v6"]:;
	}

	# Basic rules
	ferm::new::rule {
		"Respond to ICMP packets_v4":
			proto    => "icmp",
			icmptype => "echo-request",
			action   => "ACCEPT";
		"Drop UDP packets_v46":
			prio  => "a0",
			proto => "udp";
		"Nicely reject tcp packets_v46":
			prio       => "a1",
			proto      => "tcp",
			action     => "REJECT reject-with tcp-reset";
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
			action     => "REJECT reject-with tcp-reset",
			chain      => "FORWARD";
		"Reject everything else (forward)_v46":
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
