#
# Class: kbp_unbound
#
# Actions:
#  Setup unbound, monitoring and trending
#
# Depends:
#  gen_puppet
#  gen_unbound
#  kbp_munin
#  kbp_icinga
#
class kbp_unbound {
  include gen_unbound
  include kbp_icinga::unbound
  include kbp_munin::client::unbound

  if $lsbdistcodename == 'squeeze' {
    # get the backports version
    gen_apt::preference { ["unbound", "libunbound2", "unbound-anchor", "libldns1"]:; }

    # The backported version supports status
    Service <| title == "unbound" |> {
      hasstatus => true,
    }
  }

  concat::add_content { "05 unbound.conf settings for trending":
    # according to: http://www.unbound.net/documentation/howto_statistics.html
    content => "\tstatistics-interval: 0\n\textended-statistics: yes\n\tstatistics-cumulative: no\n",
    target  => "/etc/unbound/unbound.conf";
  }
}

#
# Define: kbp_unbound_allow
#
# Actions:
#  Open the firewall for DNS queries and add the netblock/address to unbound.conf via gen_unbound
#
# Depends:
#  kbp_unbound
#
define kbp_unbound::allow {
  kbp_ferm::rule { "Allow DNS queries from ${name}":
    saddr  => $name,
    proto  => "(tcp udp)",
    dport  => "53",
    action => "ACCEPT";
  }

  gen_unbound::allow { $name:; }
}

#
# Define: kbp_unbound::stub_zone
#
# Actions:
#  Configure a stub-zone
#
# Parameters (see http://www.unbound.net/documentation/unbound.conf.html for info):
#  stub_host:
#   The Host the request should be forwarded to
#  stub_addr:
#   See stub_host, except that you'll have to use an IP address here
#  stub_prime:
#   true or false (see documentation for explanation)
#  stub_first:
#   true or false (see documentation for explanation)
#
# Depends:
#  kbp_unbound
#
define kbp_unbound::stub_zone ($stub_host=false, $stub_addr=false, $stub_prime=false, $stub_first=false) {
  gen_unbound::stub_zone { $name:
    stub_host  => $stub_host,
    stub_addr  => $stub_addr,
    stub_prime => $stub_prime,
    stub_first => $stub_first;
  }

  if $stub_host != 'localhost' and $stub_addr !~ /127\.0\.0\.1/ {
    kbp_ferm::rule { "Unbound stubzone ${name}":
      saddr    => $source_ipaddress,
      proto    => '(tcp udp)',
      dport    => 53,
      action   => 'ACCEPT',
      exported => true,
      ferm_tag => "unbound_stubzone_${::environment}"
    }
  }
}

#
# Define: kbp_unbound::local_zone
#
# Actions:
#  Configure a local-zone
#
# Parameters (see http://www.unbound.net/documentation/unbound.conf.html for info):
#  zonetype:
#   The type of the zone (one of 'deny','refuse','static','transparent',
#   'typetransparent','redirect','nodefault'. See documentation for explanation).
#
# Depends:
#  kbp_unbound
#
# ToDo:
#  Create a define for local-data, so puppet can add this data to the config file
#
define kbp_unbound::local_zone ($zonetype) {
  gen_unbound::local_zone { $name:
    zonetype => $zonetype;
  }
}
