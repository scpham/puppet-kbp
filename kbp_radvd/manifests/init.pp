#
# Class: kbp_radvd
#
# Actions:
#  Install radvd and set some sysctl stuff to allow IPv6 forwarding.
#  This class is called from kbp_radvd::prefix and doesn't need to be included directly.
#
# Depends:
#  sysctl
#
class kbp_radvd {
  include sysctl
  sysctl::setting {
    ['net.ipv6.conf.default.autoconf', 'net.ipv6.conf.default.accept_ra', 'net.ipv6.conf.default.accept_ra_defrtr',
     'net.ipv6.conf.default.accept_ra_rtr_pref', 'net.ipv6.conf.default.accept_ra_pinfo', 'net.ipv6.conf.default.accept_source_route',
     'net.ipv6.conf.default.accept_redirects', 'net.ipv6.conf.all.autoconf', 'net.ipv6.conf.all.accept_ra',
     'net.ipv6.conf.all.accept_ra_defrtr', 'net.ipv6.conf.all.accept_ra_rtr_pref', 'net.ipv6.conf.all.accept_ra_pinfo',
     'net.ipv6.conf.all.accept_source_route', 'net.ipv6.conf.all.accept_redirects']:
      value => '0';
    ['net.ipv6.conf.default.forwarding', 'net.ipv6.conf.all.forwarding']:
      value => '1';
  }
}

#
# Define: kbp_radvd::prefix
#
# Actions:
#  Setup a Router Advertisment for a prefix on an interface.
#
# Parameters:
#  interface:
#   The interface the advertisment should be sent out on.
#  prefix:
#   The IPv6 prefix (in the form of 1:2:2:3::/64) to be announced on this interface
#
# Depends:
#  kbp_radvd
#
define kbp_radvd::prefix ($interface, $prefix) {
  include kbp_radvd
  gen_radvd::prefix { $name:
    interface => $interface,
    prefix    => $prefix;
  }
}
