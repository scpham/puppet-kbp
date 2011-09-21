# Author: Kumina bv <support@kumina.nl>


class kbp_haproxy ($failover = false, $customtag="haproxy_${environment}", $loglevel="warning") {
	include kbp_trending::haproxy

	class { "gen_haproxy":
		failover  => $failover,
		loglevel  => $loglevel,
		customtag => $customtag;
	}
	Gen_ferm::Rule <<| tag == $customtag |>>
}

# Define: kbp_haproxy::site
#
# Parameters:
#	listenaddress
#		The external IP to listen to
#	port
#		The external port to listen on
#	monitor_site
#		Should this website be monitored?
#	monitoring_ha
#		Is this a High Availibility (24/7) service?
#	monitoring_url
#		The URL to be monitored, should be a status page of some sort
#	monitoring_response
#		The response we should expect from monitoring_url
#	cookie
#		The cookie option from HAProxy(see http://haproxy.1wt.eu/download/1.4/doc/configuration.txt)
#	httpcheck_uri
#		The URI to check if the backendserver is running
#	httpcheck_port
#		The port to check on whether the backendserver is running
#	servername
#		The hostname(or made up name) for the backend server
#	serverport
#		The port for haproxy to connect to on the backend server
#	serverip
#		The IP of the backend server
#	balance
#		The balancing-method to use
#	customtag="haproxy_${environment}"
#		Change this when there are multiple loadbalancers in one environment
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_haproxy::site ($listenaddress, $port=80, $monitor_site=true, $monitoring_ha=false, $monitoring_url=false, $monitoring_response=false, $cookie=false, $make_lbconfig, $httpcheck_uri=false, $httpcheck_port=false, $balance="static-rr", $max_check_attempts=false, $servername=$hostname, $serverip=$ipaddress_eth0, $serverport=80, $customtag="haproxy_${environment}") {
	gen_ferm::rule { "HAProxy forward for ${name}":
		proto     => "tcp",
		daddr     => $listenaddress,
		dport     => $port,
		action    => "ACCEPT",
		exported  => true,
		customtag => $customtag;
	}

	if $make_lbconfig {
		gen_haproxy::site { "${name}":
			listenaddress  => $listenaddress,
			port           => $port,
			cookie         => $cookie,
			httpcheck_uri  => $httpcheck_uri,
			httpcheck_port => $httpcheck_port,
			balance        => $balance,
			servername     => $servername,
			serverip       => $serverip,
			serverport     => $serverport,
			customtag      => $customtag;
		}
	}

	if $monitor_site {
		kbp_monitoring::haproxy { "${name}":
			address            => $listenaddress,
			ha                 => $monitoring_ha,
			url                => $monitoring_url,
			port               => $serverport,
			max_check_attempts => $max_check_attempts,
			response           => $monitoring_response;
			}
	}
}
