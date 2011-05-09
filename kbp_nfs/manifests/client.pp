class kbp_nfs::client {
	include gen_nfs::client
	include kbp_trending::client::nfs
}

class kbp_nfs::client::trending::munin {
	
}

define kbp_nfs::client::mount ($source) {
	include kbp_nfs::client

	gen_nfs::client::mount { $name:
		source => $source,
	}

	# Exclude this mount from the backups
	line { "Exclude NFS mount ${name} from backups.":
		file    => "/etc/backup/excludes",
		content => "${name}",
		require => Kpackage["offsite-backup"],
	}
}
