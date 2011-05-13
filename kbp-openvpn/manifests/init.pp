class kbp-openvpn::server inherits openvpn::server {
	include munin::client

	munin::client::plugin { "openvpn":
		require => File["/etc/openvpn/openvpn-status.log"],
	}

	munin::client::plugin::config { "openvpn":
		content => "user root\n",
	}

	# The Munin plugin has hardcoded the location of the status log, so we
	# need this symlink.
	file { "/etc/openvpn/openvpn-status.log":
		ensure => link,
		target => "/var/lib/openvpn/status.log",
	}

	ferm::rule { "OpenVPN connections":
		proto  => "udp",
		dport  => 1194,
		action => "ACCEPT";
	}

	ferm::mod {
		"INVALID (forward)_v4":
			chain  => "FORWARD",
			mod    => "state",
			param  => "state",
			value  => "INVALID",
			action => "DROP";
		"ESTABLISHED RELATED (forward)_v4":
			chain  => "FORWARD",
			mod    => "state",
			param  => "state",
			value  => "(ESTABLISHED RELATED)",
			action => "ACCEPT";
	}
}
