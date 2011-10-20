# Author: Kumina bv <support@kumina.nl>

# Class: kbp_physical
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_physical {
	include kbp_arpwatch

	case $raidcontroller0_driver {
		"3w-9xxx": {
			kpackage { "3ware-cli-binary":; }

			kbp_monitoring::raidcontroller { "controller0":
				driver => "3ware";
			}
		}
		"aacraid": {
			kpackage { "arcconf":; }

			kbp_monitoring::raidcontroller { "controller0":
				driver => "adaptec";
			}
		}
	}

	if $consolefqdn != -1 {
		kbp_icinga::virtualhost { "${consolefqdn}":
			address => $consoleaddress,
			parents => $consoleparent,
			proxy   => $consoleproxy;
		}

		if !$consoleipmi {
			kbp_monitoring::http { "http_${consolefqdn}":
				customfqdn => $consolefqdn;
			}
		}
	}

	# Backup the MBR
	kfile { "/etc/backup/prepare.d/mbr":
		source => "kbp_physical/mbr",
		mode   => 700;
	}
}
