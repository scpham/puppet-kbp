# Author: Kumina bv <support@kumina.nl>

# Class: kbp_mailscanner
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_mailscanner {
  include gen_amavisd-new
  include munin::client
  include kbp_mailscanner::spamchecker
  include kbp_mailscanner::virusscanner

  file { "/etc/amavis/conf.d/40-kbp":
    content => template("kbp_mailscanner/amavis/conf.d/40-kbp"),
    require => Package["amavisd-new"],
    notify => Service["amavis"],
  }

  package { ["zoo", "arj", "cabextract"]:
    notify => Service["amavis"],
  }

  munin::client::plugin { ["amavis_time", "amavis_cache", "amavis_content"]:
    script => "amavis_",
    script_path => "/usr/local/share/munin/plugins",
  }

  munin::client::plugin::config { "amavis_":
    section => "amavis_*",
    content => "env.amavis_db_home /var/lib/amavis/db\nuser amavis",
  }
}

# Class: kbp_mailscanner::spamchecker
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_mailscanner::spamchecker inherits spamassassin {
  file { "/etc/spamassassin/local.cf":
    content => template("kbp_mailscanner/spamassassin/local.cf"),
    notify => Service["amavis"],
  }

  # Pyzor and Razor work similarly (they both use checksums for detecting
  # spam), but the details differ.
  # http://spamassassinbook.packtpub.com/chapter11.htm has a good
  # description on the differences.
  package { ["pyzor", "razor"]:; }
}

# Class: kbp_mailscanner::virusscanner
#
# Actions:
#  Undocumented
#
# Depends:
#  Undocumented
#  gen_puppet
#
class kbp_mailscanner::virusscanner inherits clamav {
  user { "clamav":
    require => Package["clamav-daemon","amavisd-new"],
    groups => "amavis",
  }
}
