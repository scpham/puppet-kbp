class kbp_physical {
	if $consolefqdn != -1 {
		kbp_icinga::virtualhost { "${consolefqdn}":
			address => $consoleaddress,
			parents => $consoleparent;
		}

		if !$consoleipmi {
			gen_icinga::service { "http_${consolefqdn}":
				conf_dir            => "${environment}/${consolefqdn}",
				service_description => "HTTP",
				hostname            => $consolefqdn,
				checkcommand        => "check_http";
			}
		}
	}
}
