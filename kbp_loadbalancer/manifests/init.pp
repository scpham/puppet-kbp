define kbp_loadbalancer::site ($listenaddress, $port=80, $sslport=false, monitoring=true) {
	kbp_haproxy::site { "${name}":
		address    => $listenaddress,
		port       => $port,
		monitoring => $monitoring;
	}

	if $sslport {
		kbp_stunnel::site { "${name}":
			port => $sslport;
		}
	}
}
