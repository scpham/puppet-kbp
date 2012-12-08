# Author: Kumina bv <support@kumina.nl>

# Class: kbp_softflowd
#
# Actions:
#  Configure softflowd
#
# Parameters:
#   interface  The network interface to listen on (default 'eth0')
#   host       IP of NetFlow collector (default '127.0.0.1')
#   port       UDP port of the collector (default '9995')
#   version    Netflow version (default '9')
#   maxlife    Max lifetime of a flow (default '5m' (= five minutes))
#   expint     Flow expire interval, expint=0 means expire immediately (default '0')
#
# Depends:
#  gen_puppet
#  gen_softflowd
#  kbp_icinga
#
class kbp_softflowd ($interface='eth0', $host='127.0.0.1', $port='9995', $version='9', $maxlife='5m', $expint='0') {
  $nf_collector = "${host}:${port}"

  class { 'gen_softflowd':
    interface => $interface,
    host      => $host,
    port      => $port,
    version   => $version,
    maxlife   => $maxlife,
    expint    => $expint;
  }

  kbp_icinga::service { "softflowd":
    service_description => "softflowd daemon",
    check_command       => "check_softflowd",
    nrpe                => true;
  }
}
