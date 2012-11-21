# Author: Kumina bv <support@kumina.nl>


class kbp_haproxy ($failover = false, $haproxy_loglevel="warning") {
  include kbp_trending::haproxy

  class { "gen_haproxy":
    failover         => $failover,
    haproxy_loglevel => $haproxy_loglevel;
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
define kbp_haproxy::site ($site, $monitor_site=true, $monitoring_ha=false, $monitoring_status="200", $monitoring_url=false, $monitoring_response=false, $monitoring_address=$listenaddress, $monitoring_hostname=$name,
    $cookie=false, $httpcheck_port=false, $balance="static-rr", $max_check_attempts=false, $servername=$hostname, $serverip=$ipaddress_eth0, $serverport=80, $timeout_connect="15s", $timeout_server_client="20s",
    $timeout_http_request="10s", $tcp_sslport=false, $monitoring_proxy=false, $httpcheck_uri=false, $forwardfor_except=false, $httpclose=false, $timeout_server="20s", $sslport=false, $redirect_non_ssl=false) {
  $ip        = regsubst($name, '(.*)_.*', '\1')
  $temp_port = regsubst($name, '.*_(.*)', '\1')
  $port      = $temp_port ? {
    $real_name => 80,
    default    => $temp_port,
  }
  $safe_name = regsubst($site, '[^a-zA-Z0-9\-_]', '_', 'G')

  kbp_ferm::rule { "HAProxy forward for ${site} (${name})":
    proto  => "tcp",
    daddr  => $ip ? {
      "0.0.0.0" => undef,
      default   => $ip,
    },
    dport  => $port,
    action => "ACCEPT";
  }

  gen_haproxy::site { "${ip}_${port}":
    site                  => $site,
    balance               => $balance,
    cookie                => $cookie,
    timeout_connect       => $timeout_connect,
    timeout_server_client => $timeout_server_client,
    timeout_http_request  => $timeout_http_request,
    httpcheck_uri         => $httpcheck_uri,
    forwardfor_except     => $forwardfor_except,
    httpclose             => $httpclose,
    timeout_server        => $timeout_server,
    redirect_non_ssl      => $redirect_non_ssl;
  }

  if $tcp_sslport {
    gen_haproxy::site { "${ip}_443":
      site                  => $site,
      mode                  => 'tcp',
      balance               => $balance,
      cookie                => $cookie,
      timeout_connect       => $timeout_connect,
      timeout_server_client => $timeout_server_client,
      timeout_http_request  => $timeout_http_request,
      httpcheck_uri         => $httpcheck_uri,
      forwardfor_except     => $forwardfor_except,
      httpclose             => $httpclose,
      timeout_server        => $timeout_server;
    }

    kbp_ferm::rule { "HAProxy forward for ${site} (${name}) over SSL":
      proto  => "tcp",
      daddr  => $ip,
      dport  => "443",
      action => "ACCEPT";
    }
  }

  if $monitor_site {
    if $tcp_sslport {
      $real_sslport = $tcp_sslport
    } elsif $sslport {
      $real_sslport = $sslport
    } else {
      $real_sslport = false
    }

    if $real_sslport {
      kbp_icinga::site {
        "${site}_${ip}":
          address              => $monitoring_address,
          ssl                  => true,
          ha                   => $monitoring_ha,
          statuscode           => $monitoring_status,
          path                 => $monitoring_url,
          host_name            => $monitoring_hostname,
          port                 => $real_sslport,
          max_check_attempts   => $max_check_attempts,
          response             => $monitoring_response,
          vhost                => false,
          proxy                => $monitoring_proxy,
          preventproxyoverride => true;
        "${site}_${ip}_ssl_local":
          service_description  => "Vhost ${name} SSL",
          address              => $monitoring_address,
          ssl                  => true,
          ha                   => $monitoring_ha,
          statuscode           => $monitoring_status,
          path                 => $monitoring_url,
          host_name            => $monitoring_hostname,
          port                 => $real_sslport,
          max_check_attempts   => $max_check_attempts,
          response             => $monitoring_response,
          nrpe                 => true;
      }
    }

    kbp_icinga::site {
      "${site}_${ip}":
        address              => $monitoring_address,
        ha                   => $monitoring_ha,
        statuscode           => $redirect_non_ssl ? {
          false => $real_sslport ? {
            false   => $monitoring_status,
            default => "${monitoring_status},301",
          },
          true  => 301,
        },
        path                 => $monitoring_url,
        host_name            => $monitoring_hostname,
        port                 => $port,
        max_check_attempts   => $max_check_attempts,
        response             => $redirect_non_ssl ? {
          true    => false,
          default => $monitoring_response,
        },
        vhost                => false,
        proxy                => $monitoring_proxy,
        preventproxyoverride => true;
      "${site}_${ip}_local":
        service_description  => "Vhost ${name}",
        address              => $monitoring_address,
        ha                   => $monitoring_ha,
        statuscode           => $redirect_non_ssl ? {
          false => $real_sslport ? {
            false   => $monitoring_status,
            default => "${monitoring_status},301",
          },
          true  => 301,
        },
        path                 => $monitoring_url,
        host_name            => $monitoring_hostname,
        port                 => $port,
        max_check_attempts   => $max_check_attempts,
        response             => $redirect_non_ssl ? {
          true    => false,
          default => $monitoring_response,
        },
        nrpe                 => true;
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
  $server_name = regsubst($name, '.*;(.*)', '\1')
  $ip          = regsubst($name, '(.*)_.*;.*', '\1')

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
    gen_haproxy::site::add_server { "${ip}_${tcp_sslport};${server_name}":
      cookie             => $cookie,
      httpcheck_uri      => $httpcheck_uri,
      httpcheck_port     => $httpcheck_port,
      httpcheck_interval => $httpcheck_interval,
      httpcheck_fall     => $httpcheck_fall,
      httpcheck_rise     => $httpcheck_rise,
      backupserver       => $backupserver,
      serverip           => $serverip,
      serverport         => $tcp_sslport;
    }
  }
}
