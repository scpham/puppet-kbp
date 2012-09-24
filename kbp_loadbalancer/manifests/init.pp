# Author: Kumina bv <support@kumina.nl>

class kbp_loadbalancer ($failover=true, $loadbalancer_tag="${environment}_${dcenv}", $heartbeat_dev='eth0', $heartbeat_ip=$ipaddress_eth0) {
  class { 'kbp_haproxy':
    failover => $failover;
  }

  if $failover {
    include kbp_pacemaker
    class { 'kbp_heartbeat':
      node_dev      => $heartbeat_dev,
      node_ip       => $heartbeat_ip,
      heartbeat_tag => $loadbalancer_tag;
    }

    kbp_pacemaker::group { 'ALL_IPs':; }

    kbp_pacemaker::primitive { 'HAProxy':
      provider         => 'lsb:haproxy',
      monitor_interval => '10s';
    }

    kbp_pacemaker::colocation { 'IPs_with_proxy':
      resource_1 => 'ALL_IPs',
      resource_2 => 'HAProxy';
    }

    kbp_pacemaker::order { 'haproxy_after_ALL_IPs':
      resource_1 => 'ALL_IPs',
      resource_2 => 'HAProxy';
    }
  }

  Kbp_loadbalancer::Ip <<| tag == "loadbalancer_${loadbalancer_tag}" |>>
  Kbp_haproxy::Site::Add_server <<| tag == "haproxy_${loadbalancer_tag}" |>>
}

define kbp_loadbalancer::ip ($exported=true, $ip, $loadbalancer_tag="${environment}_${dcenv}", $port=80, $location=false, $servername=$fqdn, $serverip=$ipaddress, $serverport=80, $cookie=false, $httpcheck_uri=false,
    $httpcheck_port=$serverport, $balance='roundrobin', $timeout_connect='10s', $timeout_server_client='10s', $timeout_http_request='10s', $tcp_sslport=false, $monitoring_ha=false, $monitoring_hostname=false, $monitoring_status='200',
    $monitoring_url=false, $monitoring_max_check_attempts=false, $monitoring_response=false, $monitoring_proxy=false, $nic='eth0', $monitoring_address=false, $sslport=false, $httpcheck_interval=false, $httpcheck_fall=false,
    $httpcheck_rise=false, $backupserver=false, $monitor_site=true, $export_done=false, $netmask=32) {
  if ! $exported {
    $real_name = regsubst($name, '(.*);(.*)', '\1')
    $real_servername = regsubst($name, '(.*);(.*)', '\2') ? {
      $name   => $servername,
      default => regsubst($name, '(.*);(.*)', '\2'),
    }
    $safe_name = regsubst($real_name, '[^a-zA-Z0-9\-_]', '_', 'G')

    if ! defined(Kbp_pacemaker::Primitive[$safe_name]) {
      kbp_pacemaker::primitive { $safe_name:
        provider         => 'ocf:heartbeat:IPaddr2',
        start_timeout    => '300s',
        monitor_interval => '10s',
        params           => "ip=\"${ip}\" cidr_netmask=\"${netmask}\" nic=\"${nic}\"",
        location         => $location,
        group            => 'ALL_IPs';
      }
    }

    if ! defined(Kbp_haproxy::Site[$real_name]) {
      kbp_haproxy::site { $real_name:
        listenaddress         => $ip,
        port                  => $port,
        monitor_site          => $monitor_site,
        monitoring_ha         => $monitoring_ha,
        max_check_attempts    => $max_check_attempts,
        monitoring_status     => $monitoring_status,
        monitoring_url        => $monitoring_url,
        monitoring_response   => $monitoring_response,
        monitoring_address    => $monitoring_address,
        monitoring_hostname   => $monitoring_hostname,
        balance               => $balance,
        timeout_connect       => $timeout_connect,
        timeout_server_client => $timeout_server_client,
        timeout_http_request  => $timeout_http_request,
        tcp_sslport           => $tcp_sslport,
        monitoring_proxy      => $monitoring_proxy,
        httpcheck_uri         => $httpcheck_uri;
      }
    }

    if $export_done {
      kbp_haproxy::site::add_server { "${real_name};${real_servername}":
        serverport         => $serverport,
        serverip           => $serverip,
        httpcheck_uri      => $httpcheck_uri,
        httpcheck_port     => $httpcheck_port,
        httpcheck_interval => $httpcheck_interval,
        httpcheck_fall     => $httpcheck_fall,
        httpcheck_rise     => $httpcheck_rise,
        tcp_sslport        => $tcp_sslport,
        backupserver       => $backupserver;
      }
    } else {
      @@kbp_haproxy::site::add_server { "${real_name};${real_servername}":
        serverport         => $serverport,
        serverip           => $serverip,
        httpcheck_uri      => $httpcheck_uri,
        httpcheck_port     => $httpcheck_port,
        httpcheck_interval => $httpcheck_interval,
        httpcheck_fall     => $httpcheck_fall,
        httpcheck_rise     => $httpcheck_rise,
        tcp_sslport        => $tcp_sslport,
        backupserver       => $backupserver,
        tag                => "haproxy_${loadbalancer_tag}";
      }
    }

    if $sslport and ! defined(Kbp_stunnel::Site[$real_name]) {
      kbp_stunnel::site { $real_name:
        port => $sslport;
      }
    }
  } else {
    @@kbp_loadbalancer::ip { "${name};${servername}":
      exported                      => false,
      export_done                   => true,
      ip                            => $ip,
      port                          => $port,
      location                      => $location,
      serverip                      => $serverip,
      serverport                    => $serverport,
      httpcheck_uri                 => $httpcheck_uri,
      httpcheck_port                => $httpcheck_port,
      httpcheck_interval            => $httpcheck_interval,
      httpcheck_fall                => $httpcheck_fall,
      httpcheck_rise                => $httpcheck_rise,
      cookie                        => $cookie,
      balance                       => $balance,
      timeout_connect               => $timeout_connect,
      timeout_server_client         => $timeout_server_client,
      timeout_http_request          => $timeout_http_request,
      tcp_sslport                   => $tcp_sslport,
      monitoring_max_check_attempts => $monitoring_max_check_attempts,
      monitoring_ha                 => $monitoring_ha,
      monitoring_hostname           => $monitoring_hostname,
      monitoring_status             => $monitoring_status,
      monitoring_response           => $monitoring_response,
      monitoring_url                => $monitoring_url,
      monitoring_proxy              => $monitoring_proxy,
      monitoring_address            => $monitoring_address,
      monitor_site                  => $monitor_site,
      nic                           => $nic,
      sslport                       => $sslport,
      backupserver                  => $backupserver,
      tag                           => "loadbalancer_${loadbalancer_tag}";
    }
  }
}
