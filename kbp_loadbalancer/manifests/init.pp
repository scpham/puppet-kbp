define kbp_loadbalancer::site ($listenaddress, $port=80, $sslport=false, $monitoring=true, $ha=false) {
	kbp_haproxy::site { "${name}":
		listenaddress => $listenaddress,
		port          => $port,
		monitoring    => $monitoring,
		ha            => $ha;
	}

	if $sslport {
		kbp_stunnel::site { "${name}":
			port => $sslport;
		}
	}
}
