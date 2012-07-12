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
  include gen_cron
  include lvm
  include sysctl
  include kbp_acpi
  include kbp_apt
  include kbp_apt::kumina
  include kbp_icinga::client
  include kbp_puppet
  include kbp_ssh
  include kbp_sysctl
  include kbp_time
  include kbp_vim
  include kbp_dashboard::client
  include kbp_dashboard_new::client
  include kbp_mcollective::server
  include kbp_ferm
  include kbp_nagios::nrpe
  include kbp_user::admin_users
  # Needed for 'host'
  if $lsbdistcodename == 'wheezy' {
    include gen_base::libisccc80
  } else {
    include gen_base::libisccc60
  }
  if $is_virtual == "false" {
    include kbp_physical
  }
  if $fqdn != "puppetmaster.kumina.nl" {
    include kbp_puppet::default_config
  }
  # Needed by elinks on squeeze and older
  if $lsbdistcodename != 'wheezy' {
    include gen_base::libmozjs2d
  }
  if $lsbdistcodename != 'lenny' {
    # Needed by grub2
    include gen_base::libfreetype6
  }

  kbp_postfix { "postfix":; }

  if $lsbdistcodename != 'wheezy' {
    kbp_ksplice { "ksplice":; }
  }

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
    purge_on_pm => true,
    owner       => "root",
    group       => "root",
    mode        => 0644,
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

  # Packages we like and want :)
  include gen_base::rsync
  package {
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

  if versioncmp($lsbdistrelease, 6.0) < 0 {
    package { "tcptrack":
      ensure => latest,
    }
  }

  file {
    "/etc/motd.tail":
      content => template("kbp_base/motd.tail");
    "/etc/console-tools/config":
      content => template("kbp_base/console-tools/config"),
      require => Package["console-tools"];
  }

  exec {
    "uname -snrvm | tee /var/run/motd ; cat /etc/motd.tail >> /var/run/motd":
      refreshonly => true,
      path => ["/usr/bin", "/bin"],
      require => File["/etc/motd.tail"],
      subscribe => File["/etc/motd.tail"];
  }

  # kerberos 5 libs: not used explicitly, but as a dependency; always install latest
  if versioncmp($lsbdistrelease, 6) >= 0 { # Squeeze
    include gen_base::libgssapi-krb5-2
    include gen_base::libk5crypto3
    include gen_base::libkrb5-3
    include gen_base::libkrb5support0
  }
}

# Class: kbp_base::environment
#
# Parameters:
#  None.
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_base::environment {
  include kbp_icinga::environment
  include kbp_user::environment

  kbp_dashboard::environment::wrapper { $environment:
    fullname => $customer_name;
  }
  kbp_dashboard_new::environment::wrapper { $environment:
    fullname => $customer_name;
  }

  @@kbp_smokeping::environment { $environment:; }

  kbp_smokeping::targetgroup { $environment:; }

  Kbp_munin::Alert_export <<| |>>

  # Create random offsets for Munin cronjob, to spread the load.
  $offset = fqdn_rand(5)
  $sync_offset = fqdn_rand(30)

  @@kbp_munin::environment { $environment:
    offset      => $offset,
    sync_offset => $sync_offset;
  }
}

class kbp_base::wanted_packages {
  include gen_base::libpam-modules
  include gen_base::libpam-runtime
  include gen_base::libpam0g
  include gen_base::realpath
  include gen_base::dnsutils
  include gen_base::wget
  include gen_base::telnet_ssl
  include gen_base::curl
  include gen_base::bzip2
  include gen_base::nscd
  include gen_base::elinks
  include gen_base::dpkg
  include gen_base::perl
  include gen_base::module_init_tools
  include gen_base::sysstat
  include gen_base::file
  include gen_base::base-files
}
