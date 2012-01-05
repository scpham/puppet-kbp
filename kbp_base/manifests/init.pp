# Author: Kumina bv <support@kumina.nl>

# Class: kbp_base
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_base {
  include kbp_base::wanted_packages
  include gen_base::dnsutils
  include gen_base::wget
  include gen_base::telnet_ssl
  include gen_cron
  include lvm
  include sysctl
  include kbp_acpi
  include kbp_apt
  include kbp_apt::kumina
  include kbp_monitoring::client
  include kbp_puppet
  include kbp_ssh
  include kbp_sysctl
  include kbp_time
  include kbp_vim
  include kbp_dashboard::client
  include kbp_munin::client
  include kbp_mcollective::server
  include kbp_ferm
  include kbp_nagios::nrpe
  if $is_virtual == "false" {
    include kbp_physical
  }
  if $fqdn != "puppetmaster.kumina.nl" {
    include kbp_puppet::default_config
  }
  # Needed by elinks
  include gen_base::libmozjs2d
  if versioncmp($lsbdistrelease, 6) >= 0 { # Squeeze
    # Needed by grub2
    include gen_base::libfreetype6
  }

  kbp_postfix { "postfix":; }

  kbp_ksplice { "ksplice":; }

  kbp_syslog { "syslog":; }

  kbp_backup::client { "backup":; }

  gen_sudo::rule {
    "User root has total control":
      entity            => "root",
      as_user           => "ALL",
      command           => "ALL",
      password_required => true;
    "Kumina default rule":
      entity            => "%root",
      as_user           => "ALL",
      command           => "ALL",
      password_required => true;
  }

  concat { "/etc/ssh/kumina.keys":
    owner => "root",
    group => "root",
    mode  => 0644,
  }

  # Fix an oops..... remove this commit in 3 days
  kfile { "/etc/default/rcS":
      source => "kbp_base/rcS";
  }

  # Force fsck on boot to repair the file system if it is inconsistent,
  # so we don't have to open the console and run fsck by hand
  #augeas { "/etc/default/rcS":
  #  lens    => "Shellvars.lns",
  #  incl    => "/files/etc/default/rcS",
  #  changes => "set FSCKFIX yes";
  #}

  # Add the Kumina group and users
  # XXX Needs to do a groupmod when a group with gid already exists.
  group { "kumina":
    ensure => present,
    gid => 10000,
  }

  # Set the LAST_UID in /etc/adduser.conf to 9999, so automatically created users will have a UID below 10k
  augeas { "/etc/adduser.conf":
    lens    => "Shellvars.lns",
    incl    => "/etc/adduser.conf",
    changes => "set LAST_UID 9999";
  }

  kbp_base::staff_user {
    "tim":
      fullname      => "Tim Stoop",
      uid           => 10001,
      password_hash => "BOGUS",
      sshkeys       => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCcRYiKZ1yPUU8+oRaDI/TyRSyFu2fwbknvr/Q3rwbQZm2K8iTfY4/WUeu/oSZOnCn5uoNjGax88RZx92DK0yYpOHtUwG/nShtTwte0Mx4zW8Sfq343OPle2b2gp/0V6dx1Nq21rmQrh0Ql23Thmi33cmKUvPgwYXvsIKfM68J2bG9+hIiucQX0AY7oH8UCX6uJmjOB2nPBsCMAmBHLsfV9LTvSobYAJLEt0m2wV+BqPZW5zLj7HyrGCDa5+85EB4MuQsiYuVdAjQJ3JF/FD0w7LrtuwhKZuS/Qwn4vXah1FlTBlIfw6IxWrQ0+CBCx4h/E4lbxgLTHCB4sanhUGKQtVV1/CFEA9GYCtDbNepFmjuZM1IubarpJmMicOebIW6yT9/035jKuS+nJG2xOLfV4MNPDkuAwqgg1DJ1JmqpG8y1+rHuswbXhlxlfKw/SEooH6I8NDv+TxHSkyo5siacNRsfQ8rQf9fKJdhD0twZuOZU8Zz9wpFz6VCYMkgKp05U= smartcard Tim Stoop\n";
    "pieter":
      fullname      => "Pieter Lexis",
      uid           => 10005,
      password_hash => "BOGUS",
      sshkeys       => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCitP9QOGYxCEqueFl/FC+K7o4hjA5zqG+oMirkqxE0EOX6VgwbigvIfzHnUI/LPkDCinhZGnFyfrTkvepcf6Bhtml3ex3lU2HvAiwVfrf/PWeNeg+MUYo7QGpqRUpC+qE82Epe8f0CLpwYo9Bzk4k4Toc1ZMvHUFzSOEBSe9tUetGmP7AGK/WDGJ5hc07XYV1/W3CAGO8XnhIS3/WdDS8D65iOXNQbwrndIfDn2Y3bWfd4qtx+KdY3+LU+6QKPS9Pdl5iYpWw3gln6NMoG8VDCaCNsr9qFNPOD26ninAGkzv31l59xIS94knutgCsov5KdxEWkd49m0ts5L+H9kZ+sznCr4I1Ng3CghABSU9gK7qnQbQR8PlM+eetyzrEFqHYApioyC2xAYJ+D6f65E7WadZBX5DZpqVEYZmw3d3rN49JI9DYlimUKA0Mu7KVfAURZ/3uir3HPZ0tBcyfqKEfT50Nqew92idjnoO191+lyvXXoiAc65EC/y5Ze8ZZ3pfU= pieter@kumina.nl\n";
    "rutger":
      fullname      => "Rutger Spiertz",
      uid           => 10003,
      password_hash => "BOGUS",
      sshkeys       => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCMZBz0sRqmfs4QT4dXVQeMIc+PdDChsjSUQv+SkN//z+igMw6qe5acC8EXUk5CR7VfaOjttp+sgoOxsvFPdFnrcozUsssnUynfVQ4GHCpDu0iOoUtz+WuGGonauAimhFsO2apkYLlO2qipt/z6B+bPQsbOxIVLpLLCa1kFKux7Td4vGddxbCxtFECd/4QUuS42G5q8nET3cdiqHM+QHXs1bnOqa6nxOxhnKX1jlqPT5nwdd8pI+RChGcjD4UofL9IYtz+Nd8wZi/h0tcOUh/ORV1bpJFwTCdWwaQ7Z7bf2Aanzn6iJz14nM0n19EOdvcB5NS/1mE54U9S3qJN+fQT3bOm47R07BIXmCEah6uZUAezkzsnXAsntgn2YDZFhjX+6Xd0iALAlhOyOMVfjJ0cq/qv1WhqScyOOETZhwOjLm4lewigpRnctJBt87p8MArPTBbJJA4TayC9eP6IfZ6plu0Be+W+xvrh/ga3oxMiyg6LWCf2yeTRUut7aIyswxY8= rutger@kumina.nl\n";
    "ed":
      fullname      => "Ed Schouten",
      uid           => 10004,
      password_hash => "BOGUS",
      shell         => "zsh",
      sshkeys       => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXah/YknMvN7CCOAK642FZfnXYVZ2uYZsy532v8pOISzH9W8mJ4FqBi0g1oAFhTZs0VNc9ouNfMDG178LSITL+ui/6T9exOEd4a0pCXuArVFmc5EVEUl3F+/qZPcOnWs7e3KaiV1dGLYDI0LhdG9ataHHR3sSPI/YAhroDLDTSVqFURXL7eyqR/aEv7nPEkY4zhQQzTECSQdadwEtGnovjNNL2aEj8rVVle5lVjbSk4N7x0ixyb4eTPB1z5FnwAlVkxHhTnsxTK28ulkrVCgKE30KS97dRG/EjA81pOzajRYTyLztqSkJnpKpL/lPfUCG7VkNfQKF+0O/KRhUfr2zb cardno:00050000057D\n";
    "thomas":
      fullname      => "Thomas Ronner",
      uid           => 10006,
      password_hash => "BOGUS",
      sshkeys       => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCSqpjh3qeW8bXvyy1eej+2ief63+4Vr6I7D+cz9UHFXwSA+/q4Aiz5PxVmsTBWvYqo8QQJAlQy4c861WSnMU73Vg9srjBbryGJNHt4DNfnEK2XnOsA246ifwSMXoW2W/cE1gfq6HRR9uL3+ysM9jRYfBvuKuGYb8+3WOdjia6W0CHsHcnhOVVBzfvhekbya9xsROT2cN1/c57JjM+9L3VTiYhLzRBNHKyAkazlpBM6d6A2u+Tq99ovEI2gqrPxsnLqaubGWz1/OdeNCM50pvwi3XCjPJU2jRPUOqpZa0NodOXcpRw44vHAdzwCk3qINWuXhDg0NiXMZ2SU/VDBF4DcjEQiwERyagYStWPuvwcHYw6Yy0GTvESTjZ8eQQg9MrwClo18zcnsirgZSP31Untt5SpvwnVcwZyRrw0i3VVW9nmlxfzbNPXid2VO4SDQ4+8D4zf6ozlumWb1RlafHtKNcI55r3lGoJwKB1NAfTE/cKm1pU1Y5gBBtI85yPCv30k= cardno:000500000C24\n";
  }

  # Extra configuration for Tim
  kfile { "/home/tim/.tmux.conf":
    source => "kbp_base/home/tim/.tmux.conf",
  }

  # Packages we like and want :)
  kpackage {
    ["bash","binutils","console-tools","zsh"]:
      ensure => installed;
    ["hidesvn","bash-completion","bc","tcptraceroute","diffstat","host","whois","pwgen"]:
      ensure => latest;
  }

  # We run Ksplice, so always install the latest debian kernel
  include gen_base::linux-base
  class { "gen_base::linux-image":
    version => $kernelrelease;
  }

  include gen_base::base-files

  if versioncmp($lsbdistrelease, 6.0) < 0 {
    kpackage { "tcptrack":
      ensure => latest,
    }
  }

  kfile {
    "/etc/motd.tail":
      source   => "kbp_base/motd.tail";
    "/etc/console-tools/config":
      source  => "kbp_base/console-tools/config",
      require => Package["console-tools"];
  }

  exec {
    "uname -snrvm | tee /var/run/motd ; cat /etc/motd.tail >> /var/run/motd":
      refreshonly => true,
      path => ["/usr/bin", "/bin"],
      require => File["/etc/motd.tail"],
      subscribe => File["/etc/motd.tail"];
  }
}

# Class: kbp_base::environment
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_base::environment {
  include kbp_monitoring::environment
  include kbp_user::environment

  Kbp_dashboard::Customer_entry_export <<| |>>

  @@kbp_dashboard::environment { $environment:
    fullname => $customer_name;
  }

  @@kbp_smokeping::environment { $environment:; }

  kbp_smokeping::targetgroup { $environment:; }

  Kbp_munin::Alert_export <<| |>>

  @@kbp_munin::environment { $environment:; }
}

class kbp_base::wanted_packages {
  include gen_base::libpam-modules
  include gen_base::libpam-runtime
  include gen_base::libpam0g
  include gen_base::realpath
}

define kbp_base::staff_user($ensure="present", $fullname, $uid, $password_hash, $sshkeys="", $shell="bash") {
    user { $name:
      comment      => $fullname,
      ensure       => $ensure,
      gid          => "kumina",
      uid          => $uid,
      groups       => ["adm", "staff", "root"],
      membership   => "minimum",
      shell        => "/bin/${shell}",
      home         => "/home/${name}",
      password     => $password_hash,
      require      => [File["/etc/skel/.bash_profile"], Package[$shell]];
    }

    if $ensure == "present" {
      kfile {
        "/home/${name}":
          ensure  => directory,
          mode    => 750,
          owner   => $name,
          group   => "kumina",
          require => [User[$name], Group["kumina"]];
        "/home/${name}/.ssh":
          ensure  => directory,
          mode    => 700,
          owner   => $name,
          group   => "kumina";
        "/home/${name}/.ssh/authorized_keys":
          content => $sshkeys,
          owner   => $name,
          group   => "kumina",
          notify  => Kaugeas["sshd_config PermitRootLogin"];
        "/home/${name}/.${shell}rc":
          content => template("kbp_base/home/${name}/.${shell}rc"),
          owner   => $name,
          group   => "kumina";
        "/home/${name}/.bash_profile":
          source  => "kbp_base/home/${name}/.bash_profile",
          owner   => $name,
          group   => "kumina";
        "/home/${name}/.bash_aliases":
          source  => "kbp_base/home/${name}/.bash_aliases",
          owner   => $name,
          group   => "kumina";
        "/home/${name}/.tmp":
          ensure  => directory,
          owner   => $name,
          group   => "kumina";
        "/home/${name}/.gitconfig":
          content => template("kbp_base/git/.gitconfig"),
          group   => "kumina";
        "/home/${name}/.reportbugrc":
          content => "REPORTBUGEMAIL=${name}@kumina.nl\n",
          group   => "kumina";
      }

      postfix::alias { "${name}: ${name}@kumina.nl":; }

      concat::add_content { "Add ${name} to Kumina SSH keyring":
        target  => "/etc/ssh/kumina.keys",
        content => "# ${fullname} <${name}@kumina.nl>\n${sshkeys}";
      }
    } else {
      kfile { "/home/${name}":
        ensure  => absent,
        force   => true,
        recurse => true;
      }
    }
  }

