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
class kbp_rabbitmq($version, $port = 5672, $ssl_cert = false, $ssl_key = false, $ssl_port = 5671, $namespace = '/') {
	class { "gen_rabbitmq":
		ssl_cert => $ssl_cert,
		ssl_key  => $ssl_key,
		ssl_port => $ssl_port,
		version  => $version;
	}

	class { "kbp_icinga::rabbitmqctl":
		namespace => $namespace,
	}

	Gen_ferm::Rule <<| tag == "rabbitmq_${environment}" |>> {
		dport => $ssl_cert ? {
			false   => $port,
			default => "(${port} ${ssl_port})",
		},
		proto  => "tcp",
		action => "ACCEPT",
	}
}

# Class: kbp_rabbitmq::client
#
# Actions:
#	Export the firewall rules we need so we can access the server.
#
# Depends:
#	gen_ferm
#	gen_puppet
#
class kbp_rabbitmq::client {
	@@gen_ferm::rule {
		"Connections to RabbitMQ for ${fqdn}":
			saddr  => $fqdn,
			tag    => "rabbitmq_${environment}",
	}
}
