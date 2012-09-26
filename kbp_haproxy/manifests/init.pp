# Author: Kumina bv <support@kumina.nl>


class kbp_haproxy ($failover = false, $loglevel="warning") {
  include kbp_trending::haproxy

  class { "gen_haproxy":
    failover => $failover,
    loglevel => $loglevel;
  }

  if ! $failover {
    kbp_icinga::proc_status { 'haproxy':; }
  }
}

# Define: kbp_haproxy::site
#
# Parameters:
#  listenaddress
#    The external IP to listen to
#  port
#    The external port to listen on
#  monitor_site
#    Should this website be monitored?
#  monitoring_ha
#    Is this a High Availability (24/7) service?
#  monitoring_status
#    The statuscode the monitoring should receive
#  monitoring_url
#    The URL to be monitored, should be a status page of some sort
#  monitoring_response
#    The response we should expect from monitoring_url
#  balance
#    The balancing-method to use
#  timeout_connect
#    TCP connection timeout between proxy and server
#  timeout_server_client
#    TCP connection timeout between client and proxy and Maximum time for the server to respond to the proxy
#  timeout_http_request
#    Maximum time for HTTP request between client and proxy
#  monitoring_proxy
#    Host to use as nrpe proxy
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_haproxy::site ($listenaddress, $port=80, $monitor_site=true, $monitoring_ha=false, $monitoring_status="200", $monitoring_url=false, $monitoring_response=false, $monitoring_address=false, $monitoring_hostname=false,
    $cookie=false, $httpcheck_port=false, $balance="static-rr", $max_check_attempts=false, $servername=$hostname, $serverip=$ipaddress_eth0, $serverport=80, $timeout_connect="15s", $timeout_server_client="20s",
    $timeout_http_request="10s", $tcp_sslport=false, $monitoring_proxy=false, $httpcheck_uri=false) {
  $real_name = regsubst($name, '(.*);(.*)', '\1')
  $safe_name = regsubst($real_name, '[^a-zA-Z0-9\-_]', '_', 'G')

  kbp_ferm::rule { "HAProxy forward for ${real_name}":
    proto  => "tcp",
    daddr  => $listenaddress ? {
      "0.0.0.0" => undef,
      default   => $listenaddress,
    },
    dport  => $port,
    action => "ACCEPT";
  }

  gen_haproxy::site { $real_name:
    listenaddress         => $listenaddress,
    port                  => $port,
    balance               => $balance,
    timeout_connect       => $timeout_connect,
    timeout_server_client => $timeout_server_client,
    timeout_http_request  => $timeout_http_request,
    httpcheck_uri         => $httpcheck_uri;
  }

  if $tcp_sslport {
    gen_haproxy::site { "${real_name}_ssl":
      listenaddress         => $listenaddress,
      port                  => "443",
      mode                  => "tcp",
      balance               => $balance,
      timeout_connect       => $timeout_connect,
      timeout_server_client => $timeout_server_client,
      timeout_http_request  => $timeout_http_request,
      httpcheck_uri         => $httpcheck_uri;
    }

    kbp_ferm::rule { "HAProxy forward for ${real_name}_ssl":
      proto  => "tcp",
      daddr  => $listenaddress,
      dport  => "443",
      action => "ACCEPT";
    }
  }

  if $monitor_site {
    kbp_icinga::haproxy::site { $real_name:
      address              => $monitoring_address ? {
        false   => $listenaddress,
        default => $monitoring_address,
      },
      ssl                  => $tcp_sslport ? {
        false   => false,
        default => true,
      },
      ha                   => $monitoring_ha,
      statuscode           => $monitoring_status,
      url                  => $monitoring_url,
      host_name            => $monitoring_hostname ? {
        false   => $real_name,
        default => $monitoring_hostname,
      },
      port                 => $port,
      max_check_attempts   => $max_check_attempts,
      response             => $monitoring_response,
      nrpe_proxy           => $monitoring_proxy,
      preventproxyoverride => true;
    }
  }
}

# Define: kbp_haproxy::site::add_server
#
# Parameters:
#  cookie
#    The cookie option from HAProxy(see http://haproxy.1wt.eu/download/1.4/doc/configuration.txt)
#  httpcheck_uri
#    The URI to check if the backendserver is running
#  httpcheck_port
#    The port to check on whether the backendserver is running
#  httpcheck_interval
#    The interval in ms, determines how often the check should run
#  httpcheck_fall
#    The number of times a check should fail before the resource is considered down
#  httpcheck_rise
#    The number of times a check should succeed after downtime before the resource is considered up
#  backupserver
#    Whether this server is a backupserver or a normal one
#  servername
#    The hostname(or made up name) for the backend server
#  serverport
#    The port for haproxy to connect to on the backend server
#  serverip
#    The IP of the backend server
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_haproxy::site::add_server ($cookie=false, $httpcheck_uri=false, $httpcheck_port=false, $httpcheck_interval=false, $httpcheck_fall=false, $httpcheck_rise=false, $backupserver=false, $serverip=$ipaddress_eth0, $serverport=80,
    $tcp_sslport=false) {
  $site_name = regsubst($name, '(.*);(.*)', '\1')
  $server_name = regsubst($name, '(.*);(.*)', '\2')
  $safe_name = regsubst($site_name, '[^a-zA-Z0-9\-_]', '_', 'G')

  gen_haproxy::site::add_server { $name:
    cookie             => $cookie,
    httpcheck_uri      => $httpcheck_uri,
    httpcheck_port     => $httpcheck_port,
    httpcheck_interval => $httpcheck_interval,
    httpcheck_fall     => $httpcheck_fall,
    httpcheck_rise     => $httpcheck_rise,
    backupserver       => $backupserver,
    serverip           => $serverip,
    serverport         => $serverport;
  }

  if $tcp_sslport {
    gen_haproxy::site::add_server { "${site_name}_ssl;${server_name}":
      httpcheck_uri      => $httpcheck_uri,
      httpcheck_port     => $tcp_sslport,
      httpcheck_interval => $httpcheck_interval,
      httpcheck_fall     => $httpcheck_fall,
      httpcheck_rise     => $httpcheck_rise,
      backupserver       => $backupserver,
      serverip           => $serverip,
      serverport         => $tcp_sslport,
    }
  }
}
