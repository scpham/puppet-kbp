class kbp-mailscanner inherits amavisd-new {
	include munin::client
	include kbp-mailscanner::spamchecker
	include kbp-mailscanner::virusscanner

	kfile { "/etc/amavis/conf.d/40-kbp":
		source => "kbp-mailscanner/amavis/conf.d/40-kbp",
		require => Package["amavisd-new"],
		notify => Service["amavis"],
	}

	kpackage { ["zoo", "arj", "cabextract"]:
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

class kbp-mailscanner::spamchecker inherits spamassassin {
	kfile { "/etc/spamassassin/local.cf":
		source => "kbp-mailscanner/spamassassin/local.cf",
		notify => Service["amavis"],
	}

	# Pyzor and Razor work similarly (they both use checksums for detecting
	# spam), but the details differ.
	# http://spamassassinbook.packtpub.com/chapter11.htm has a good
	# description on the differences.
	kpackage { ["pyzor", "razor"]:; }
}

class kbp-mailscanner::virusscanner inherits clamav {
	user { "clamav":
		require => Package["clamav-daemon","amavisd-new"],
		groups => "amavis",
	}
}
