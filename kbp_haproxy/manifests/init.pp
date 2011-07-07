# Author: Kumina bv <support@kumina.nl>

# Define: kbp_haproxy::site
#
# Parameters:
#	port
#		Undocumented
#	make_lbconfig
#		Undocumented
#	monitoring
#		Undocumented
#	ha
#		Undocumented
#	cookie
#		Undocumented
#	url
#		Undocumented
#	response
#		Undocumented
#	server_options
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
define kbp_haproxy::site ($listenaddress, $port=80, $monitoring=true, $ha=false, $cookie=false, $url=false, $response=false, $server_options=false, $make_lbconfig=true, $max_check_attempts=false) {
	gen_ferm::rule { "HAProxy forward for ${name}":
		proto  => "tcp",
		dport  => $port,
		action => "ACCEPT";
	}

	if $make_lbconfig {
		gen_haproxy::site { "${name}":
			listenaddress  => $listenaddress,
			port           => $port,
			cookie         => $cookie,
			server_options => $server_options;
		}
	}

	if $monitoring {
		kbp_monitoring::haproxy { "${name}":
			address            => $listenaddress,
			ha                 => $ha,
			url                => $url ? {
				false   => undef,
				default => $url,
			},
			max_check_attempts => $max_check_attempts,
			response           => $response ? {
				false   => undef,
				default => $response,
			};
		}
	}
}
