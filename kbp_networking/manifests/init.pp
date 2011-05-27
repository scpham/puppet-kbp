class kbp_networking {
	include gen_puppet::concat
	concat { "/etc/network/interfaces.puppet":; }
	define interface_ip ($interface=eth0, $address, $netmask, $gateway) {
		gen_puppet::concat::add_content { "${name}":
			target  => "/etc/network/interfaces.puppet",
			content => template("kbp_networking/interfaces.erb");
		}
	}

	gen_puppet::concat::add_content { "The loopback interface":
		target  => "/etc/network/interfaces.puppet",
		content => "# The loopback interface\nauto lo\niface lo inet loopback\n",
		order   => 10;
	}
}
