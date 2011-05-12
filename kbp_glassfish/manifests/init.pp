class kbp_glassfish {
	define site($domain = "domain1", $serveralias = [], $with_ssl = false, $port = "80", $sslport = "443", $redundant=true) {
		if $domain != "domain1" and !$redundant {
			kbp_glassfish::monitoring::icinga::site { "${name}":; }
		}
	}
}

class kbp_glassfish::monitoring::icinga {
	define site () {
		kbp_icinga::host { "${name}":; }

		kbp_icinga::service {
			"glassfish_domain_${name}":
				service_description => "Glassfish domain ${name}",
				check_command       => "check_http_vhost",
				argument1           => $name;
		}
	}
}
