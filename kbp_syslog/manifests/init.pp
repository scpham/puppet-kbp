# Author: Kumina bv <support@kumina.nl>

# Class: kbp_syslog::server
#
# Parameters:
#	environmentonly
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::server($environmentonly=false) {
	include "kbp_syslog::server::$lsbdistcodename"

	if ($environmentonly) {
		Gen_ferm::Rule <<| tag == "syslog_${environment}" |>>
	} else {
		Gen_ferm::Rule <<| tag == "syslog" |>>
	}
}

# Class: kbp_syslog::client
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::client($environmentonly=false){
	include "kbp_syslog::client::$lsbdistcodename"

	@@gen_ferm::rule { "Syslog traffic from ${fqdn}":
		saddr  => $fqdn,
		proto  => "udp",
		dport  => 514,
		action => "ACCEPT",
		tag    => $environmentonly ? {
			false   => ["syslog","syslog_${environment}"],
			default => "syslog_${environment}",
		};
	}
}

# Class: kbp_syslog::server::etch
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::server::etch inherits syslog-ng::server {
	kfile { "/etc/logrotate.d/syslog-ng":
		source => "kbp_syslog/server/logrotate.d/syslog-ng";
	}
}

# Class: kbp_syslog::client::etch
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::client::etch inherits sysklogd::client {
}

# Class: kbp_syslog::server::lenny
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::server::lenny inherits rsyslog::server {
	include kbp_syslog::server::logrotate
}

# Class: kbp_syslog::client::lenny
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::client::lenny inherits rsyslog::client {
}

# Class: kbp_syslog::server::squeeze
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::server::squeeze inherits rsyslog::server {
	include kbp_syslog::server::logrotate
}

# Class: kbp_syslog::server::logrotate
#
# Action:
#	Setup logrotation to our defaults for syslog and companions.
#
# Depends:
#	gen_logrotate::rotate
#	gen_puppet
#
class kbp_syslog::server::logrotate {
	gen_logrotate::rotate { "rsyslog":
		logs       => ["/var/log/syslog", "/var/log/mail.info", "/var/log/mail.warn", "/var/log/mail.err", "/var/log/mail.log", "/var/log/daemon.log",
			"/var/log/kern.log", "/var/log/auth.log", "/var/log/user.log", "/var/log/lpr.log", "/var/log/cron.log", "/var/log/debug",
			"/var/log/messages"],
		options    => ["daily", "rotate 90", "missingok", "notifempty", "compress", "delaycompress", "sharedscripts", "dateext"],
		postrotate => "invoke-rc.d rsyslog reload > /dev/null";
	}

	include kbp_syslog::cleanup
}

# Class: kbp_syslog::client::squeeze
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::client::squeeze inherits rsyslog::client {
}

# Additional options
# Class: kbp_syslog::server::mysql
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::server::mysql {
	include kbp_syslog::server
	include "kbp_syslog::mysql::$lsbdistcodename"
}

# Class: kbp_syslog::mysql::etch
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::mysql::etch {
	err ("This is not implemented for Etch or earlier!")
}

# Class: kbp_syslog::mysql::lenny
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_syslog::mysql::lenny inherits rsyslog::mysql {
}

# Class: kbp_syslog::cleanup
#
# Actions:
#	Cleans up old syslog files. This class is a temporary workaround.
#
# Depends:
#	gen_puppet
#
class kbp_syslog::cleanup {
	$numbers = ["90","89","88","87","86","85","84","83","82","81","80","79"]

	cleanup { $numbers:; }

	define cleanup {
		$files = ["syslog.${name}","mail.info.${name}","mail.warn.${name}","mail.err.${name}","mail.log.${name}",
			  "daemon.log.${name}","kern.log.${name}","auth.log.${name}","user.log.${name}","lpr.log.${name}",
			  "cron.log.${name}","debug.log.${name}","messages.${name}"]
		
		cleanup0 { $files:; }
	}

	define cleanup0 {
		$base = "/var/log/"
		file { ["${base}/${name}","${base}/${name}.gz"]:
			ensure => absent,
		}
	}
}
