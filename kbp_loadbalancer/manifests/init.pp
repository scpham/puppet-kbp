define kbp_loadbalancer::site ($listenaddress, $port=80, $sslport=false, $monitoring=true, $ha=false, $url=false, $response=false, $make_lbconfig=true) {
	kbp_haproxy::site { "${name}":
		listenaddress => $listenaddress,
		port          => $port,
		monitoring    => $monitoring,
		ha            => $ha,
		url           => $url ? {
			false   => undef,
			default => $url,
		},
		response      => $response ? {
			false   => undef,
			default => $response,
		},
		make_lbconfig => $make_lbconfig;
	}

	if $sslport {
		kbp_stunnel::site { "${name}":
			port => $sslport;
		}
	}
}
