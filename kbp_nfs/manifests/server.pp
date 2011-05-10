class kbp_nfs::server ($default_config = true) {
	include gen_nfs::server
	include kbp_trending::nfsd

	if $default_config { include kbp_nfs::server::default_config }
}

class kbp_nfs::server::default_config {
	# Use this for a default NFS server
	gen_nfs::server::config { "dummy for nfs server":
		incoming_port => "4000",
		outgoing_port => "4001",
		rpcmountdopts => "--state-directory-path /srv/nfs",
		statdopts     => "--state-directory-path /srv/nfs",
	}

	ferm::new::rule { "Ports for nfsd":
		proto  => "(tcp udp)",
		dport  => "(4000 4001)",
		action => "ACCEPT";
	}
}
