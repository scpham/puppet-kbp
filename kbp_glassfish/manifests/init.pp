define kbp_glassfish::domain($adminport, $jmxport, $webport=false) {
	ferm::new::rule {
		"Glassfish admin panel for ${name}":
			proto  => "tcp",
			dport  => $adminport,
			action => "ACCEPT",
			tag    => "ferm_glassfish_rule";
		"Glassfish JMX port for ${name}":
			proto  => "tcp",
			dport  => $jmxport,
			action => "ACCEPT"
			tag    => "ferm_glassfish_rule";
	}

	if $webport {
		ferm::new::rule {
			"Glassfish web for ${name}":
				proto  => "tcp",
				dport  => $webport,
				action => "ACCEPT"
				tag    => "ferm_glassfish_rule";
		}
	}
}

define kbp_glassfish::site($domain = "domain1", $serveralias = [], $with_ssl = false, $port = "80", $sslport = "443", $redundant=true) {
	if $domain != "domain1" and !$redundant {
		kbp_glassfish::monitoring::icinga::site { "${name}":; }
	}
}

define kbp_glassfish::monitoring::icinga::site () {
	kbp_icinga::host { "${name}":; }

	kbp_icinga::service {
		"glassfish_domain_${name}":
			service_description => "Glassfish domain ${name}",
			check_command       => "check_http_vhost",
			argument1           => $name;
	}
}
