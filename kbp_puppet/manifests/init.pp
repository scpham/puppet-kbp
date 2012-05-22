# Author: Kumina bv <support@kumina.nl>

# Class: kbp_puppet
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_puppet {
  include gen_puppet

#  exec { "Mount /var with acl":
#    command => '/usr/bin/awk \'/var/ { if($4 !~ /acl/) $4 = $4",acl" } ; { print }\' /etc/fstab > /etc/fstab.net && mv /etc/fstab{.net,} && /bin/mount -o remount /var';
#  }

#  setfacl { "/var/lib/puppet_group":
#    dir          => "/var/lib/puppet",
#    acl          => "group:kumina:rwx",
#    make_default => true,
#    require      => Exec["Mount /var with acl"];
#  }

  # We backport the squeeze-backports versions to lenny-kumina
  gen_apt::preference { ["puppet","puppet-common","facter"]:
    repo => $lsbdistcodename ? {
      "lenny"   => "lenny-kumina",
      "squeeze" => "squeeze-backports",
      default   => $lsbdistcodename,
    };
  }

  # Pin augeas to lenny-backports for lenny
  if $lsbdistcodename == "lenny" {
    gen_apt::preference { ["libaugeas-ruby", "libaugeas-ruby1.8", "augeas-lenses", "libaugeas0", "augeas-tools"]:;}
  }

  Kbp_puppet::Settestpms <<| |>>
}

# Class: kbp_puppet::test_default_config
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_puppet::default_config {
  include gen_puppet::puppet_conf

  # Default config for all our puppet clients
  gen_puppet::set_config {
    "logdir":      value => '/var/log/puppet';
    "vardir":      value => '/var/lib/puppet';
    "ssldir":      value => '/var/lib/puppet/ssl';
    "rundir":      value => '/var/run/puppet';
    # Single quotes in the next resources prevent them being expanded
    "factpath":    value => '$vardir/lib/facter';
    "templatedir": value => '$confdir/templates';
    "pluginsync":  value => 'true';
    "environment": value => $environment;
    "configtimeout":
      value   => '1800',
      section => 'agent';
    "runinterval":
      value   => 10800,
      section => "agent";
    "splay":
      value   => 'true',
      section => "agent";
    "splaylimit":
      value   => 10800,
      section => "agent";
    "server":
      value   => 'puppet1.kumina.nl',
      section => "agent";
    "report":
      value   => 'false',
      section => "agent";
  }
}

# Class: kbp_puppet::vim
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_puppet::vim {
  include kbp_vim::puppet
}

define kbp_puppet::settestpms($testpms) {
  Concat <| |> {
    testpms => $testpms,
  }
}
