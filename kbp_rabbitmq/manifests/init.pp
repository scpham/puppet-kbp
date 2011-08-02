# Author: Kumina bv <support@kumina.nl>

# Class: kbp_rabbitmq
#
# Actions:
#	Setup a specific version of rabbitmq and deploy some config for it.
#
# Depends:
#	gen_rabbitmq
#	gen_puppet
#
class kbp_rabbitmq($version, $port = 5672, $ssl_cert = false, $ssl_key = false, $ssl_port = 5671) {
	class { "gen_rabbitmq":
		ssl_cert => $ssl_cert,
		ssl_key  => $ssl_key,
		ssl_port => $ssl_port,
		version  => $version;
	}

	Gen_ferm::Rule <<| tag == "rabbitmq_${environment}" |>> {
		dport => $port,
	}

	# Open the port for the clients
	if $ssl_cert {
		Gen_ferm::Rule <<| tag == "rabbitmq_ssl_${environment}" |>> {
			dport => $ssl_port,
		}
	}
}
