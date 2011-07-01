# Author: Kumina bv <support@kumina.nl>

# Class: kbp_debian::etch
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_debian::etch {
}

# Class: kbp_debian::lenny
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_debian::lenny {
	# Don't pull in Recommends or Suggests dependencies when installing
	# packages with apt.
	kfile {
		"/etc/apt/apt.conf.d/no-recommends":
			content => "APT::Install-Recommends \"false\";\n";
		"/etc/apt/apt.conf.d/no-suggests":
			content => "APT::Install-Suggests \"false\";\n";
	}

	gen_apt::source {
		"${lsbdistcodename}-volatile":
			comment => "Repository for volatile packages in $lsbdistcodename, such as SpamAssassin and Clamav",
			sourcetype => "deb",
			uri => "$aptproxy/debian-volatile/",
			distribution => "${lsbdistcodename}/volatile",
			components => "main";
	}

	package { "mailx":
		ensure => installed
	}

	# Package which makes sure the installed Backports.org repository key is
	# up-to-date.
	package { "debian-backports-keyring":
		ensure => installed,
	}
}

# Class: kbp_debian::squeeze
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_debian::squeeze {
	# Don't pull in Recommends or Suggests dependencies when installing
	# packages with apt.
	kfile {
		"/etc/apt/apt.conf.d/no-recommends":
			content => "APT::Install-Recommends \"false\";\n";
		"/etc/apt/apt.conf.d/no-suggests":
			content => "APT::Install-Suggests \"false\";\n";
	}

	gen_apt::source {
		"${lsbdistcodename}-updates":
			    comment => "Repository for update packages in $lsbdistcodename, such as SpamAssassin and Clamav",
			    sourcetype => "deb",
			    uri => "$aptproxy/debian/",
			    distribution => "${lsbdistcodename}-updates",
			    components => "main";
	}

	kpackage { "bsd-mailx":
		ensure => installed;
	}
}

# Class: kbp_debian
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_debian inherits kbp_base {
	$aptproxy = "http://apt-proxy.sys.kumina.nl:9999"

	include "kbp_debian::$lsbdistcodename"
	include rng-tools

	define check_alternatives($linkto) {
		exec { "/usr/sbin/update-alternatives --set $name $linkto":
			unless => "/bin/sh -c '[ -L /etc/alternatives/$name ] && [ /etc/alternatives/$name -ef $linkto ]'"
		}
	}

	# Packages we want to have installed
	$wantedpackages = ["openssh-server", "less", "lftp", "screen", "file", "debsums", "dlocate", "gnupg",
		"ucf", "elinks", "reportbug", "tree", "netcat", "openssh-client", "tcpdump", "iproute", "acl",
		"psmisc", "udev", "lsof", "bzip2", "strace", "pinfo", "lsb-release", "ethtool", "socat", "make", "nscd"]
	kpackage { $wantedpackages:
		ensure => installed;
	}

	package { "ca-certificates":
		ensure => installed;
	}

	# Packages we do not need, thank you very much!
	$unwantedpackages = ["pidentd", "dhcp3-client",
	  "dictionaries-common", "doc-linux-text", "doc-debian",
	   "iamerican", "ibritish", "ispell", "laptop-detect", "libident",
	   "mpack", "mtools", "popularity-contest", "procmail", "tcsh",
	   "w3m", "wamerican", "ppp", "pppoe", "pppoeconf", "at", "mdetect",
	   "tasksel"]
	kpackage { $unwantedpackages:
		ensure => absent;
	}

	# Local timezone
	package { "tzdata":
		ensure => latest,
	}

	kfile {
		"/etc/timezone":
			content => "Europe/Amsterdam\n",
			require => Package["tzdata"];
		"/etc/localtime":
			ensure => link,
			target => "/usr/share/zoneinfo/Europe/Amsterdam",
			require => Package["tzdata"];
	}

	# Ensure /tmp always has the correct permissions. (It's a common
	# mistake to forget to do a chmod 1777 /tmp when /tmp is moved to its
	# own filesystem.)
	kfile { "/tmp":
		mode => 1777,
	}

	service { "ssh":
		ensure => running,
		require => Package["openssh-server"],
	}

	# We want to use pinfo as infobrowser, so when the symlink is not
	# pointing towards pinfo, we need to run update-alternatives
	check_alternatives { "infobrowser":
		linkto => "/usr/bin/pinfo",
		require => Package["pinfo"]
	}

	kfile { "/etc/skel/.bash_profile":
		source => "kbp_debian/skel/bash_profile";
	}

	package { "adduser":
		ensure => installed,
	}

	kfile { "/etc/adduser.conf":
		source => "kbp_debian/adduser.conf",
		require => Package["adduser"],
	}

	package {
		"locales":
			require => File["/var/cache/debconf/locales.preseed"],
			responsefile => "/var/cache/debconf/locales.preseed",
			ensure => installed;
	}

	kfile {
		"/var/cache/debconf/locales.preseed":
			source => "kbp_debian/locales.preseed";
	}

	# Mail on upgrades with cron-apt
	kpackage { "cron-apt":; }

	kfile { "/etc/cron-apt/config":
		source => "kbp_debian/cron-apt/config",
		require => Package["cron-apt"],
	}

	gen_apt::source {
		"${lsbdistcodename}-base":
			comment => "The main repository for the installed Debian release: $lsbdistdescription.",
			sourcetype => "deb",
			uri => "$aptproxy/debian/",
			distribution => "${lsbdistcodename}",
			components => "main non-free";
		"${lsbdistcodename}-security":
			comment => "Security updates for $lsbdistcodename.",
			sourcetype => "deb",
			uri => "$aptproxy/security/",
			distribution => "${lsbdistcodename}/updates",
			components => "main";
		"${lsbdistcodename}-backports":
			comment => "Repository for packages which have been backported to $lsbdistcodename.",
			sourcetype => "deb",
			uri => "$aptproxy/backports",
			distribution => "${lsbdistcodename}-backports",
			components => "main contrib non-free",
			require => Gen_apt::Key["16BA136C"];
		"kumina":
			comment => "Local repository, for packages maintained by Kumina.",
			sourcetype => "deb",
			uri => "$aptproxy/kumina/",
			distribution => "${lsbdistcodename}-kumina",
			components => "main",
			require => Gen_apt::Key["498B91E6"];
	}

	# Package which makes sure the installed Kumina repository key is up-to-date.
	kpackage { "kumina-archive-keyring":
		ensure => latest;
	}

	gen_apt::preference { "all":
		package => "*",
		repo    => "${lsbdistcodename}-kumina";
	}

	# TODO: move to appropriate modules (ticket 588)
	if $lsbdistcodename == "lenny" {
		gen_apt::preference { ["libvirt-bin","virtinst","libvirt-doc","libvirt0","facter","virt-manager","libasound2","libbrlapi0.5","kvm","rake","python-django","varnish","linux-image-2.6-amd64","firmware-bnx2","drbd8-utils","heartbeat","python-support"]:; }
	}
}
