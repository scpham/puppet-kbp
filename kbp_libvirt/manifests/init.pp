class kbp_libvirt inherits libvirt {
	include munin::client

	ferm::mod { "Allow bridged packets":
		chain  => "FORWARD",
		mod    => "physdev",
		param  => "physdev-is-bridged",
		action => "ACCEPT";
	}

	kfile {
		"/etc/libvirt/qemu/networks/default.xml":
			require => Kpackage["libvirt-bin"],
			ensure  => absent;
		"/etc/libvirt/storage":
			ensure  => directory,
			require => Kpackage["libvirt-bin"],
			mode    => 755;
		"/etc/libvirt/storage/autostart":
			ensure  => directory,
			require => Kfile["/etc/libvirt/storage"],
			mode    => 755;
		"/etc/libvirt/storage/guest.xml":
			source  => "kbp_libvirt/libvirt/storage/guest.xml",
			require => Kfile["/etc/libvirt/storage"];
		"/etc/libvirt/storage/autostart/guest.xml":
			ensure  => "/etc/libvirt/storage/guest.xml",
			require => Kfile["/etc/libvirt/storage/autostart"];
	}

	if versioncmp($lsbdistrelease, "5.0") < 0 {
		munin::client::plugin { ["libvirt-blkstat", "libvirt-cputime", "libvirt-ifstat", "libvirt-mem"]:
			require     => [Kpackage["python-libvirt", "python-libxml2"],Munin::Client::Plugin::Config["libvirt"]],
			script_path => "/usr/local/share/munin/plugins";
		}

		kpackage { ["python-libxml2","python-libvirt"]:
			ensure => latest;
		}
	} else {
		kpackage { "munin-libvirt-plugins":
			ensure => latest,
		}

		munin::client::plugin { ["libvirt-blkstat", "libvirt-cputime", "libvirt-ifstat", "libvirt-mem"]:
			require     => [Kpackage["munin-libvirt-plugins"],Munin::Client::Plugin::Config["libvirt"]],
			script_path => "/usr/share/munin/plugins";
		}
	}

	munin::client::plugin::config { "libvirt":
		section => "libvirt-*",
		content => "user root";
	}
}
