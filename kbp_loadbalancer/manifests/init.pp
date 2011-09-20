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
define kbp_loadbalancer::site ($sslport=false, $listenaddress, $port=80, $monitor_site=true, $monitoring_ha=false, $cookie=false, $monitoring_url=false, $monitoring_response=false, $make_lbconfig=true, $httpcheck_uri=false, $httpcheck_port=false, $servername=$::hostname, $serverip=$::ipaddress_eth0, $serverport=80, $balance="static-rr", $max_check_attempts=false, $lb_timeout_connect="15s", $lb_timeout_server_client="20s", $lb_timeout_http_request="10s", $customtag=false) {
	kbp_haproxy::site { "${name}":
		listenaddress         => $listenaddress,
		port                  => $port,
		monitor_site          => $monitoring_site,
		monitoring_ha         => $monitoring_ha,
		max_check_attempts    => $max_check_attempts,
		monitoring_url        => $monitoring_url,
		monitoring_response   => $monitoring_response,
		balance               => $balance,
		servername            => $servername,
		serverport            => $serverport,
		serverip              => $serverip,
		httpcheck_uri         => $httpcheck_uri,
		httpcheck_port        => $httpcheck_port,
		cookie                => $cookie,
		timeout_connect       => $lb_timeout_connect,
		timeout_server_client => $lb_timeout_server_client,
		timeout_http_request  => $lb_timeout_http_request,
		make_lbconfig         => $make_lbconfig,
		haproxy_tag           => $customtag ? {
			false   => undef,
			default => $customtag,
		};
	}

	if $sslport {
		kbp_stunnel::site { "${name}":
			port => $sslport;
		}
	}
}

class kbp_loadbalancer ($failover=false, $customtag=false) {
	class { "kbp_haproxy":
		failover  => $failover,
		haproxy_tag => $customtag ? {
			false   => undef,
			default => $customtag,
		};
	}
}
