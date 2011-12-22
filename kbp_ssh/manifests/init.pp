# Author: Kumina bv <support@kumina.nl>

# Class: kbp_ssh
#
# Actions:
#  Setup ssh the way we want it
#
# Depends:
#  kbp_openssl::common
#  gen_ferm::rule
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

  @@sshkey { $fqdn:
    host_aliases => $ipaddress,
    type         => ssh-rsa,
    key          => $sshrsakey,
    tag          => "sshkey_${environment}",
    ensure       => present;
  }

  Sshkey <<| tag == "sshkey_${environment}" |>>

  # Disable password logins and root logins
  kaugeas {
    "sshd_config PermitRootLogin":
      lens    => 'Sshd.lns',
      file    => "/etc/ssh/sshd_config",
      changes => "set PermitRootLogin no",
      notify  => Service["ssh"];
    "sshd_config PasswordAuthentication":
      lens    => 'Sshd.lns',
      file    => "/etc/ssh/sshd_config",
      changes => "set PasswordAuthentication no",
      notify  => Service["ssh"];
  }
}

# Class: kbp_ssh::permit_root_logins_with_forced_commands
#
# Actions:
#  Allow root logins with forced commands only
#
# Depends:
#  kbp_ssh
#  gen_puppet
#
class kbp_ssh::permit_root_logins_with_forced_commands {
  Kaugeas <| title == "sshd_config PermitRootLogin" |> {
    changes => "set PermitRootLogin forced-commands-only",
  }
}
