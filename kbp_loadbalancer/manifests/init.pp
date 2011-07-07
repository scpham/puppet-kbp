# Author: Kumina bv <support@kumina.nl>

# Define: kbp_loadbalancer::site
#
# Parameters:
#	port
#		Undocumented
#	sslport
#		Undocumented
#	monitoring
#		Undocumented
#	ha
#		Undocumented
#	url
#		Undocumented
#	response
#		Undocumented
#	make_lbconfig
#		Undocumented
#	listenaddress
#		Undocumented
#	max_check_attempts
#		The number of retries before the monitoring considers the site down.
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_loadbalancer::site ($listenaddress, $port=80, $sslport=false, $monitoring=true, $ha=false, $url=false, $response=false, $make_lbconfig=true, $max_check_attempts=false) {
	kbp_haproxy::site { "${name}":
		listenaddress      => $listenaddress,
		port               => $port,
		monitoring         => $monitoring,
		ha                 => $ha,
		max_check_attempts => $max_check_attempts,
		url                => $url ? {
			false   => undef,
			default => $url,
		},
		response           => $response ? {
			false   => undef,
			default => $response,
		},
		make_lbconfig      => $make_lbconfig;
	}

	if $sslport {
		kbp_stunnel::site { "${name}":
			port => $sslport;
		}
	}
}
