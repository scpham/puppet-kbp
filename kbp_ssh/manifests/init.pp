# Author: Kumina bv <support@kumina.nl>

# Class: kbp_ssh
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_ssh {
	include gen_openssl::common
	gen_ferm::rule { "SSH":
		proto  => "tcp",
		dport  => "22",
		action => "ACCEPT",
		tag    => "ferm";
	}


# DISABLED SO LENNY BOXES CAN KICK
	# Disable password logins and root logins
#	augeas { "sshd_config":
#		context => "/files/etc/ssh/sshd_config",
#		changes => [
#			"set PermitRootLogin no",
#			"set PasswordAuthentication no"
#		],
#		notify  => Service["ssh"];
#	}
}
