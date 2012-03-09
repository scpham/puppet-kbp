# Author: Kumina bv <support@kumina.nl>

# Class: kbp_apt
#
# Actions:
#  Setup APT the way we like it.
#
# Depends:
#  gen_apt
#  gen_puppet
#
class kbp_apt {
  include gen_apt

  # Keys for ksplice, jenkins, rabbitmq (in this order)
  gen_apt::key {
    "B6D4038E":
      content => template("kbp_apt/keys/B6D4038E");
    "D50582E6":
      content => template("kbp_apt/keys/D50582E6");
    "056E8E56":
      content => template("kbp_apt/keys/056E8E56");
  }

  gen_apt::cron_apt::config {
    # First, update the package list and don't mail us. A second run is done to see if there are packages to be installed
    # Because puppet could have updated them in the meantime.
    "update":
      mailon      => "", # Don't send mail
      mailto      => "reports",
      crontime    => "0 20 * * *", # 8 in the evening
      configfile  => "/etc/cron-apt/config";
    # Now mail if we need to upgrade packages by hand
    "mail for manual upgrade":
      mailon      => "upgrade",
      mailto      => "reports",
      crontime    => "0 4 * * *", # 4 in the morning
      apt_options => "-V",
      configfile  => "/etc/cron-apt/config-mail";
  }
}

# Class: kbp_apt::kumina
#
# Actions:
#  Setup the APT source for the kumina repository, including keeping the key up-to-date and making sure we always prefer
#  packages that we've packaged ourselves.
#
# Depends:
#  gen_apt
#  gen_puppet
#
class kbp_apt::kumina {
  gen_apt::key { "498B91E6":
    content => template("kbp_apt/keys/498B91E6");
  }

  gen_apt::source {
    "kumina":
      comment      => "Kumina repository.",
      sourcetype   => "deb",
      uri          => "http://debian.kumina.nl/debian",
      distribution => "${lsbdistcodename}-kumina",
      components   => "main",
      key          => "498B91E6";
  }

  # This is the actual key, packaged.
  kpackage { ["apt-transport-https","kumina-archive-keyring"]:
    ensure => latest,
  }

  # Always prefer packages that we created ourselves.
  gen_apt::preference { "all":
    package => "*",
    repo    => "${lsbdistcodename}-kumina";
  }
}

# Class: kbp_apt::kumina
#
# Actions:
#  Setup the APT source for the kumina repository, including keeping the key up-to-date and making sure we always prefer
#  packages that we've packaged ourselves.
#
# Depends:
#  gen_apt
#  gen_puppet
#
class kbp_apt::kumina_non_free ($repopassword = "BOGUS"){
  # Pull in the key and other stuff we need
  include kbp_apt::kumina

  gen_apt::source {
    "kumina-non-free":
      comment      => "Kumina non-free repository.",
      sourcetype   => "deb",
      uri          => "https://${environment}:${repopassword}@debian-non-free.kumina.nl/debian",
      distribution => "${lsbdistcodename}-kumina",
      components   => "non-free",
      key          => "498B91E6";
  }
}
