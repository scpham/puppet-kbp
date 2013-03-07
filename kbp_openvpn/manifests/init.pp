# Author: Kumina bv <support@kumina.nl>

# Class: kbp_openvpn::server
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_openvpn::server inherits openvpn::server {
  gen_munin::client::plugin { "openvpn":
    require => File["/etc/openvpn/openvpn-status.log"],
  }

  gen_munin::client::plugin::config { "openvpn":
    content => "user root\n",
  }

  # The Munin plugin has hardcoded the location of the status log, so we
  # need this symlink.
  file { "/etc/openvpn/openvpn-status.log":
    ensure => link,
    target => "/var/lib/openvpn/status.log",
  }

  gen_ferm::rule { "OpenVPN connections":
    proto  => "udp",
    dport  => 1194,
    action => "ACCEPT";
  }

  gen_ferm::mod {
    "INVALID (forward)_v4":
      chain  => "FORWARD",
      mod    => "state",
      param  => "state",
      value  => "INVALID",
      action => "DROP";
    "ESTABLISHED RELATED (forward)_v4":
      chain  => "FORWARD",
      mod    => "state",
      param  => "state",
      value  => "(ESTABLISHED RELATED)",
      action => "ACCEPT";
  }
}

define kbp_openvpn::client ($keylocation, $ca_cert, $remote_host=$name) {
  kbp_ssl::keys { $keylocation:; }

  $certname = regsubst($keylocation,'^(.*)/(.*)$','\2')
  gen_openvpn::client { $name:
    remote_host => $remote_host,
    ca_cert     => $ca_cert,
    certname    => $certname,
    require     => File["/etc/ssl/certs/${certname}.pem", "/etc/ssl/private/${certname}.key", "/etc/ssl/certs/${ca_cert}.pem"];
  }
}
