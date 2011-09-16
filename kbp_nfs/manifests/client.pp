# Author: Kumina bv <support@kumina.nl>

# Class: kbp_nfs::client
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_nfs::client {
	include kbp_trending::nfs

	@@gen_ferm::rule { "NFS connections from ${fqdn}":
		saddr  => $fqdn,
		proto  => "(tcp udp)",
		action => "ACCEPT",
		tag    => "nfs_${environment}";
	}
}

# Define: kbp_nfs::client::mount
#
# Parameters:
#	source
#		Undocumented
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
define kbp_nfs::client::mount($server, $options, $serverpath=false) {
	include kbp_nfs::client

	$real_serverpath = $serverpath ? {
		false   => $name,
		default => $serverpath,
	}

	kbp_monitoring::nfs::client { $name:; }

	gen_nfs::mount { $name:
		source => "${server}:${real_serverpath}";
	}

	line { "Exclude NFS mount ${name} from backups.":
		file    => "/etc/backup/excludes",
		content => $name,
		require => Kpackage["offsite-backup"];
	}

	exec { "/bin/mount -o remount ${name}":
		unless  => "/bin/sh -c 'cd ${name}'",
		require => Gen_nfs::Mount["${name}"];
	}

	@@kbp_nfs::client::mount_opts { "${name} mount options for ${fqdn}":
		location => $real_serverpath,
		options  => $options,
		client   => $fqdn,
		tag      => "nfs_${environment}";
	}
}

define kbp_nfs::client::mount_opts($location, $options, client) {
	if !defined(Concat::Add_content[$location]) {
		concat::add_content {
			$location:
				content => "${location} \\",
				target  => "/etc/exports";
			"${location}zzz":
				content => "",
				target  => "/etc/exports";
		}

		kfile { "$location/.monitoring":
			content => "NFS mount ok";
		}
	}

	concat::add_content { "${location}_${client}":
		content => "${client}($options) \\",
		target  => "/etc/exports";
	}
}
