# Author: Kumina bv <support@kumina.nl>

# Class: kbp_ferm
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_ferm {
  include kbp_ferm::offenders
  include gen_ferm

  @gen_ferm::chain {
    ["PREROUTING_v4","PREROUTING_v6"]:
      table => "nat";
    ["POSTROUTING_v4","POSTROUTING_v6"]:
      table  => "nat",
      policy => "ACCEPT";
    ["ACCOUNTING_v4","ACCOUNTING_v6"]:;
  }

  # Basic rules
  gen_ferm::rule {
    "Respond to ICMP packets_v4":
      proto    => "icmp",
      icmptype => "echo-request",
      action   => "ACCEPT";
    "Drop UDP packets":
      prio  => "a0",
      proto => "udp";
    "Nicely reject tcp packets":
      prio   => "a1",
      proto  => "tcp",
      action => "REJECT reject-with tcp-reset";
    "Reject everything else":
      prio   => "a2",
      action => "REJECT";
    "Drop UDP packets (forward)":
      prio  => "a0",
      proto => "udp",
      chain => "FORWARD";
    "Nicely reject tcp packets (forward)":
      prio   => "a1",
      proto  => "tcp",
      action => "REJECT reject-with tcp-reset",
      chain  => "FORWARD";
    "Reject everything else (forward)":
      prio   => "a2",
      action => "REJECT",
      chain  => "FORWARD";
    "Respond to ICMP packets (NDP)_v6":
      prio     => 00001,
      proto    => "icmpv6",
      icmptype => "(neighbour-solicitation neighbour-advertisement)",
      action   => "ACCEPT";
    "Respond to ICMP packets (diagnostic)_v6":
      proto    => "icmpv6",
      icmptype => "echo-request",
      action   => "ACCEPT";
  }
}

# Class: kbp_ferm::offenders
#
# Parameters:
#  None
#
# Actions:
#  Disable access from known bad IP addresses to all machines in our control.
#  Use with care.
#
# Depends:
#  kbp_ferm
#  gen_puppet
#
class kbp_ferm::offenders {
  # Please add a comment describing when the IP was added and what for.
  kbp_ferm::block {
    "20110823 Ssh brute force attacks on IQNOMY for several days":
      ips => ["(180.168.201.47 114.205.1.193 115.249.181.70 119.188.7.159 119.255.18.205 124.207.65.146 188.138.88.62 188.65.81.41 ",
              "200.230.71.5 200.62.142.142 201.159.16.156 203.90.136.76 208.163.56.3 208.76.52.85 211.119.54.83 216.13.56.89 ",
              "217.11.127.103 219.111.16.42 220.160.203.27 78.159.196.233 82.177.118.13 82.177.118.14 85.214.143.232 87.106.60.104 ",
              "88.190.22.3 91.198.88.202)"];
    "20110922 Ssh brute force attack on several machines":
      ips => ["(109.74.195.29 121.101.219.231 129.21.143.91 173.213.103.90 184.107.179.50 18.85.28.253 190.154.164.177 ",
              "208.66.100.188 216.163.33.20 216.18.216.132 61.131.208.105 69.93.40.75 78.41.201.145 85.251.7.29 85.25.191.144 ",
              "91.185.197.35 98.207.90.250)"];
    "20111116 Ssh brute force attack on several machines":
      ips => ["(94.73.154.122 46.167.171.12 199.180.129.141 71.6.165.238 85.95.227.169)"];
  }
}

# Define: kbp_ferm::block
#
# Parameters:
#  name
#    Description of why these IP addresses are blocked
#  ips
#    Comma-separated list of IP addresses to block
#
# Actions:
#  Drops all traffic from the IP address.
#
# Depends:
#  kbp_ferm
#  gen_puppet
#
define kbp_ferm::block ($ips) {
  gen_ferm::rule {
    "Block IPs in INPUT chain due to: ${name}":
      saddr  => $ips,
      action => "DROP";
    "Block IPs in FORWARD chain due to: ${name}":
      saddr  => $ips,
      chain  => "FORWARD",
      action => "DROP";
  }
}

# Define: kbp_ferm::forward
#
# Parameters:
#  proto
#    Undocumented
#  port
#    Undocumented
#  dest
#    Undocumented
#  dport
#    Undocumented
#  inc
#    Undocumented
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
define kbp_ferm::forward($inc, $proto, $port, $dest, $dport) {
  gen_ferm::rule {
    "Accept all ${proto} traffic from ${inc} to ${dest}:${port}_v4":
      chain     => "FORWARD",
      interface => "eth1",
      saddr     => $inc,
      daddr     => $dest,
      proto     => $proto,
      dport     => $port,
      action    => "ACCEPT";
    "Forward all ${proto} traffic from ${inc} to ${port} to ${dest}:${dport}_v4":
      table     => "nat",
      chain     => "PREROUTING",
      daddr     => $inc,
      proto     => $proto,
      dport     => $port,
      action    => "DNAT to \"${dest}:${dport}\"";
  }
}

define kbp_ferm::rule($prio=500, $interface=false, $outerface=false, $saddr=false, $daddr=false, $proto=false,
    $icmptype=false, $sport=false, $dport=false, $jump=false, $action=DROP, $table=filter,
    $chain=INPUT, $ensure=present, $exported=false, $ferm_tag=false, $fqdn=$fqdn, $ipaddress6=$ipaddress6) {
  if ! $exported {
    gen_ferm::rule { $name:
      prio       => $prio,
      interface  => $interface,
      outerface  => $outerface,
      saddr      => $saddr,
      daddr      => $daddr,
      proto      => $proto,
      icmptype   => $icmptype,
      sport      => $sport,
      dport      => $dport,
      jump       => $jump,
      action     => $action,
      table      => $table,
      chain      => $chain,
      ensure     => $ensure,
      ferm_tag   => $ferm_tag,
      fqdn       => $fqdn,
      ipaddress6 => $ipaddress6;
    }
  } else {
    @@kbp_ferm::rule { "${name} for ${fqdn}":
      prio       => $prio,
      interface  => $interface,
      outerface  => $outerface,
      saddr      => $saddr,
      daddr      => $daddr,
      proto      => $proto,
      icmptype   => $icmptype,
      sport      => $sport,
      dport      => $dport,
      jump       => $jump,
      action     => $action,
      table      => $table,
      chain      => $chain,
      ensure     => $ensure,
      exported   => false,
      ferm_tag   => $ferm_tag,
      fqdn       => $fqdn,
      ipaddress6 => $ipaddress6 ? {
        undef   => false,
        default => $ipaddress6,
      };
    }
  }
}
