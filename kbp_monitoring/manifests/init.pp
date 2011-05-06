class kbp_monitoring::client::sslcert {
	include kbp_monitoring::client
	include kbp_sudo
	gen_sudo::rule { "check_sslcert sudo rules":
		entity => "nagios",
		as_user => "root",
		password_required => false,
		command =>"/usr/lib/nagios/plugins/check_sslcert";
	}
}

class kbp_monitoring::server($package="icinga") {
	case $package {
		"icinga": { include kbp_icinga::server }
		"nagios": { include kbp-nagios::server }
	}

	@@ferm::new::rule {
		"NRPE connections from ${fqdn}_v46":
			saddr  => "${fqdn}",
			proto  => "tcp",
			dport  => "5666",
			action => "ACCEPT",
			tag    => "ferm_general_rule";
		"MySQL connections from ${fqdn}":
			saddr  => "${fqdn}",
			proto  => "tcp",
			dport  => "3306",
			action => "ACCEPT",
			tag    => "ferm_mysql_rule_monitoring";
		"Sphinxsearch connections from ${fqdn}":
			saddr  => "${fqdn}",
			proto  => "tcp",
			dport  => "3312",
			action => "ACCEPT",
			tag    => "ferm_sphinxsearch_rule_monitoring";
	}
}
