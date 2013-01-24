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

  include kbp_icinga::emptyfirewall
  class { "kbp_icinga::ferm_config":
    filename => "/etc/ferm/ferm.conf";
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
    "20120130 Ssh brute force attack on customer":
      ips => "94.199.108.203";
    "20120130 Ssh brute force at customer":
      ips => "210.71.234.67";
    "20120216 Ssh brute force at customer":
      ips => "(211.139.95.221 211.44.183.111 212.120.241.174)";
    "20120312 Port scans on entire range":
      ips => "(208.80.127.4 222.124.21.98 212.70.217.216 77.95.229.72 80.152.154.224 199.15.252.136 140.206.35.27 212.198.163.71 219.232.244.89 222.186.24.13)";
    "20120626 Port scans on entire range":
      ips => "(210.0.207.196)";
  }

  kbp_ferm::spammer {
    "20130122 Spammer":
      ips => '77.241.91.53';
    "20130124 A company dedicated to spamming":
      ips => '78.41.64.0/27';
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

# Define: kbp_ferm::spammer
#
# Parameters:
#  name
#    Description of why these IP addresses are spammers, add a date added please
#  ips
#    List of IP addresses to block email from in ferm syntax
#
# Actions:
#  Drops all mail traffic from the IP address.
#
# Depends:
#  kbp_ferm
#  gen_puppet
#
define kbp_ferm::spammer ($ips) {
  gen_ferm::rule {
    "Block spammer in INPUT chain due to: ${name}":
      saddr  => $ips,
      proto  => 'tcp',
      dport  => '(25 465)',
      action => "DROP";
    "Block spammer in FORWARD chain due to: ${name}":
      saddr  => $ips,
      proto  => 'tcp',
      dport  => '(25 465)',
      chain  => "FORWARD",
      action => "DROP";
  }
}

# Define: kbp_ferm::forward
#
# Parameters:
#  proto
#    The protocol that should be forwarded (usually tcp, so it defaults to that)
#  listen_addr
#    The address to listen on
#  listen_port
#    The port to listen on
#  dest_addr
#    The destination address
#  dest_port
#    The destination port (on the machine that uses the destination address), defaults to
#    listen_port.
#
#  TODO inc, port, dest, dport are legacy and should be replaced.
#
# Actions:
#  Setup a forward on a specific port to another ip address and optionally another port.
#
# Depends:
#  gen_ferm
#  gen_puppet
#
# TODO:
#  Once every setup uses the new invocation, the definition header can change into:
#define kbp_ferm::forward($listen_addr, $listen_port, $dest_addr, $dest_port = false, $proto = "tcp") {
define kbp_ferm::forward($listen_addr = false, $listen_port = false, $dest_addr = false, $dest_port = false, $proto = "tcp",
                         $inc = false, $port = false, $dest = false, $dport = false) {
  # Warn about legacy
  if $inc or $port or $dest or $dport {
    notify { "The definition of kbp_ferm::forward has changed. Please update the code for this host to use the new definition! Resource: kbp_ferm::forward { ${name}:; }":; }
  }

  # Most of the following checks can be removed once the definition has changed, except for
  # the $dest_port, because that should be $listen_port if not set. TODO
  if ! $dest_port {
    if $dport { $r_dest_port = $dport       }
    else      { $r_dest_port = $listen_port }
  } else {
    $r_dest_port = $dest_port
  }

  if ! $dest_addr {
    if $dest { $r_dest_addr = $dest         }
    else     { fail('No $dest_addr given.') }
  } else {
    $r_dest_addr = $dest_addr
  }

  if ! $listen_port {
    if $port { $r_listen_port = $port         }
    else     { fail('No $listen_port given.') }
  } else {
    $r_listen_port = $listen_port
  }

  if ! $listen_addr {
    if $inc { $r_listen_addr = $inc          }
    else    { fail('No $listen_addr given.') }
  } else {
    $r_listen_addr = $listen_addr
  }

  # TODO If you remove the $r_* vars above, don't forget to change them here!
  gen_ferm::rule {
    "Accept all ${proto} traffic from ${r_listen_addr}:${r_listen_port} to ${r_dest_addr}:${r_dest_port}_v4":
      chain     => "FORWARD",
      daddr     => $r_dest_addr,
      proto     => $proto,
      dport     => $r_dest_port,
      action    => "ACCEPT";
    "Forward all ${proto} traffic from ${r_listen_addr}:${r_listen_port} to ${r_dest_addr}:${r_dest_port}_v4":
      table     => "nat",
      chain     => "PREROUTING",
      daddr     => $r_listen_addr,
      proto     => $proto,
      dport     => $r_listen_port,
      action    => "DNAT to \"${r_dest_addr}:${r_dest_port}\"";
  }
}

define kbp_ferm::rule($prio=500, $interface=false, $outerface=false, $saddr=false, $daddr=false, $proto=false,
    $icmptype=false, $sport=false, $dport=false, $jump=false, $action=DROP, $table=filter,
    $chain=INPUT, $ensure=present, $exported=false, $ferm_tag=false, $fqdn=$fqdn, $ipaddress6=$ipaddress6, $customtag="foobar") {
    if $customtag != "foobar" { notify { "kbp_ferm::rule ${name} customtag: ${customtag}":; } }
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
      fqdn       => $fqdn,
      ipaddress6 => $ipaddress6;
    }
  } else {
    if ! $saddr and ! $daddr {
      fail("Exported ferm rule ${name} has no \$saddr and no \$daddr")
    }
    if $saddr and $daddr {
      $real_name = "${name} (exported by ${fqdn})"
    } elsif $saddr {
      $real_name = "${name} from ${fqdn}"
    } else {
      $real_name = "${name} to ${fqdn}"
    }

    @@kbp_ferm::rule { $real_name:
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
      fqdn       => $fqdn,
      ipaddress6 => $ipaddress6 ? {
        undef   => false,
        default => $ipaddress6,
      },
      tag        => $ferm_tag;
    }
  }
}
