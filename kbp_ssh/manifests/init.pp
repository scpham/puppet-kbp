# Author: Kumina bv <support@kumina.nl>

# Class: kbp_ssh
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_ssh {
  include kbp_openssl::common

  gen_ferm::rule { "SSH":
    proto  => "tcp",
    dport  => "22",
    action => "ACCEPT",
    tag    => "ferm";
  }

  # remove this commit after 3 days....
  kfile { "/etc/ssh/sshd_config":
    source => "kbp_ssh/sshd_config",
    notify => Service['ssh'];
  }

  # Disable password logins and root logins
  #augeas { "sshd_config":
  #  lens    => 'Sshd.lns',
  #  incl    => "/etc/ssh/sshd_config",
  #  changes => [
  #    "set PermitRootLogin forced-commands-only",
  #    "set PasswordAuthentication no"
  #  ],
  #  notify  => Service["ssh"];
  #}
}
