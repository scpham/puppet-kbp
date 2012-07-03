# Author: Kumina bv <support@kumina.nl>

# Define: kbp_loadbalancer::site
#
# Parameters:
#  port
#    Undocumented
#  sslport
#    The port for SSL connection (when terminating ssl on the lb)
#  monitoring
#    Undocumented
#  ha
#    Undocumented
#  url
#    Undocumented
#  response
#    Undocumented
#  make_lbconfig
#    Undocumented
#  listenaddress
#    Undocumented
#  max_check_attempts
#    The number of retries before the monitoring considers the site down.
#  lb_tcp_ssl_port
#    The protnumber to create a haproxy config for tcp mode balancing for ssl sites.
#  nrpe_proxy
#    Host to use as nrpe proxy
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_loadbalancer::site ($sslport=false, $listenaddress, $port=80, $monitor_site=true, $monitoring_ha=false, $cookie=false, $monitoring_status="200", $monitoring_url=false, $monitoring_response=false, $monitoring_address=false, $monitoring_hostname = false, $make_lbconfig=true, $httpcheck_uri=false, $httpcheck_port=false, $servername=$::hostname, $serverip=$::ipaddress_eth0, $serverport=80, $balance="roundrobin", $max_check_attempts=false, $lb_timeout_connect="15s", $lb_timeout_server_client="20s", $lb_timeout_http_request="10s", $lb_tcp_sslport=false, $monitoring_proxy=false, $customtag=false) {
  kbp_haproxy::site { "${name}":
    listenaddress         => $listenaddress,
    port                  => $port,
    monitor_site          => $monitoring_site,
    monitoring_ha         => $monitoring_ha,
    max_check_attempts    => $max_check_attempts,
    monitoring_status     => $monitoring_status,
    monitoring_url        => $monitoring_url,
    monitoring_response   => $monitoring_response,
    monitoring_address    => $monitoring_address,
    monitoring_hostname   => $monitoring_hostname,
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
    tcp_sslport           => $lb_tcp_sslport,
    make_lbconfig         => $make_lbconfig,
    monitoring_proxy      => $monitoring_proxy,
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

class kbp_loadbalancer ($failover=false, $customtag=false, $forwardfor=false) {
  class { "kbp_haproxy":
    failover  => $failover,
    haproxy_tag => $customtag ? {
      false   => undef,
      default => $customtag,
    },
    forwardfor => $forwardfor;
  }
}
