# Author: Kumina bv <support@kumina.nl>

# Define: kbp_glassfish::domain
#
# Parameters:
#	jmxport
#		Undocumented
#	webport
#		Undocumented
#	java_monitoring
#		Undocumented
#	java_contact_groups
#		Undocumented
#	java_servicegroups
#		Undocumented
#	statuspath
#		Undocumented
#	adminport
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_glassfish::domain($adminport, $jmxport, $webport=false, $java_monitoring=false, $sms=true, $statuspath=false) {
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
			contact_groups => $java_contact_groups ? {
				false   => undef,
				default => $java_contact_groups,
			},
			sms            => $sms;
		}
	}

	if $webport {
		kbp_monitoring::glassfish { "${name}":
			statuspath     => $statuspath ? {
				false   => undef,
				default => $statuspath,
			},
			webport        => $webport;
		}
	}
}

# Define: kbp_glassfish::site
#
# Parameters:
#	serveralias
#		Undocumented
#	with_ssl
#		Undocumented
#	port
#		Undocumented
#	sslport
#		Undocumented
#	redundant
#		Undocumented
#	domain
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_glassfish::site($domain = "domain1", $serveralias = [], $with_ssl = false, $port = "80", $sslport = "443", $redundant=true) {
	if $domain != "domain1" and !$redundant {
		kbp_glassfish::monitoring::icinga::site { "${name}":; }
	}
}

# Define: kbp_glassfish::monitoring::icinga::site
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_glassfish::monitoring::icinga::site () {
	gen_icinga::host { "${name}":; }

	gen_icinga::service {
		"glassfish_domain_${name}":
			service_description => "Glassfish domain ${name}",
			check_command       => "check_http_vhost",
			argument1           => $name;
	}
}
