class kbp_physical {
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
			parents => $consoleparent;
		}

		if !$consoleipmi {
			kbp_monitoring::http { "http_${consolefqdn}":
				customfqdn => $consolefqdn;
			}
		}
	}
}
