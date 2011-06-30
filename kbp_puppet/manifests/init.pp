class kbp_puppet {
	include gen_puppet

	gen_apt::preference { ["puppet","puppet-common"]:; }
}

class kbp_puppet::test_default_config {
	include gen_puppet::puppet_conf

	# Default config for all our puppet clients
	gen_puppet::set_config {
		"logdir":      value => '/var/log/puppet';
		"vardir":      value => '/var/lib/puppet';
		"ssldir":      value => '/var/lib/puppet/ssl';
		"rundir":      value => '/var/run/puppet';
		# Single quotes in the next resources prevent them being expanded
		"factpath":    value => '$vardir/lib/facter';
		"templatedir": value => '$confdir/templates';
		"pluginsync":  value => 'true';
		"environment": value => $environment;
		"configtimeout":
			value   => "300",
			section => "agent";
	}
}

class kbp_puppet::vim {
	include kbp_vim::puppet
}
