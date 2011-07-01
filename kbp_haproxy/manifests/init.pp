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
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_haproxy::site ($listenaddress, $port=80, $monitoring=true, $ha=false, $cookie=false, $url=false, $response=false, $server_options=false, $make_lbconfig=true) {
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
			address  => $listenaddress,
			ha       => $ha,
			url      => $url ? {
				false   => undef,
				default => $url,
			},
			response => $response ? {
				false   => undef,
				default => $response,
			};
		}
	}
}
