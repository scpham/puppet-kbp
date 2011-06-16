define kbp_glassfish::domain($adminport, $jmxport, $webport=false, java_monitoring=false, contact_groups=false, servicegroups=false) {
	gen_ferm::rule {
		"Glassfish admin panel for ${name}":
			proto  => "tcp",
			dport  => $adminport,
			action => "ACCEPT",
			tag    => "glassfish_admin_${environment}";
		"Glassfish JMX port for ${name}":
			proto  => "tcp",
			dport  => $jmxport,
			action => "ACCEPT",
			tag    => "glassfish_jmx_${environment}";
	}

	if $webport {
		gen_ferm::rule { "Glassfish web for ${name}":
			proto  => "tcp",
			dport  => $webport,
			action => "ACCEPT",
			tag    => "glassfish_web_${environment}";
		}
	}

	if $java_monitoring {
		kbp_monitoring::java { "${name}_${jmxport}":
			contact_groups => $contact_groups ? {
				false   => undef,
				default => $contact_groups,
			},
			servicegroups  => $servicegroups ? {
				false   => undef,
				default => $servicegroups,
			};
		}
	}
}

define kbp_glassfish::site($domain = "domain1", $serveralias = [], $with_ssl = false, $port = "80", $sslport = "443", $redundant=true) {
	if $domain != "domain1" and !$redundant {
		kbp_glassfish::monitoring::icinga::site { "${name}":; }
	}
}

define kbp_glassfish::monitoring::icinga::site () {
	gen_icinga::host { "${name}":; }

	gen_icinga::service {
		"glassfish_domain_${name}":
			service_description => "Glassfish domain ${name}",
			check_command       => "check_http_vhost",
			argument1           => $name;
	}
}
