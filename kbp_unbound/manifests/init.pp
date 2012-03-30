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

  # get the backports version
  gen_apt::preference { ["unbound", "libunbound2", "unbound-anchor"]:
    repo => "${lsbdistcodename}-kumina";
  }
  gen_apt::preference { "libldns1":; }

  # Our backported version supports status
  Kservice <| title == "unbound" |> {
    hasstatus => true,
    hasreload => true,
  }

  concat::add_content { "80 unbound.conf settings for trending":
    # according to: http://www.unbound.net/documentation/howto_statistics.html
    content => "\tstatistics-interval: 0\n\textended-statistics: yes\n\tstatistics-cumulative: no",
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
