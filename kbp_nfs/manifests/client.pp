class kbp_nfs::client {
	include gen_nfs::client
}

class kbp_nfs::client::trending::munin {
	
}

define kbp_nfs::client::mount ($source) {
	gen_nfs::client::mount { $name:
		source => $source,
	}

	# Exclude this mount from the backups
	line { "Exclude NFS mount ${name} from backups.":
		file    => "/etc/backup/exclude",
		content => "${name}",
		require => Kpackage["offsite-backup"],
	}
}
