# Author: Kumina bv <support@kumina.nl>

# Class: kbp_base
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_base {
	include gen_base::dnsutils
	include gen_base::wget
	include lvm
	include sysctl
	include kbp_acpi
	include kbp_apt
	include kbp_puppet
	include kbp_ssh
	include kbp_vim
	include kbp_time
	include kbp_icinga::client
	if $is_virtual == "false" {
		include kbp_physical
	}
	if $fqdn != "puppetmaster.kumina.nl" {
		include kbp_puppet::default_config
	}

	if versioncmp($lsbdistrelease, 6) >= 0 { # Squeeze
		# Needed by grub2
		include gen_base::libfreetype6
		# Needed by elinks
		include gen_base::libmozjs2d
	}

	gen_sudo::rule {
		"User root has total control":
			entity            => "root",
			as_user           => "ALL",
			command           => "ALL",
			password_required => true;
		"Kumina default rule":
			entity            => "%root",
			as_user           => "ALL",
			command           => "ALL",
			password_required => true;
	}

	concat { "/etc/ssh/kumina.keys":
		owner => "root",
		group => "root",
		mode  => 0644,
	}

	define staff_user($ensure = "present", $fullname, $uid, $password_hash, $sshkeys = "", $shell = "bash") {
		$username = $name
		user { "$username":
			comment 	=> $fullname,
			ensure 		=> $ensure,
			gid 		=> "kumina",
			uid 		=> $uid,
			groups 		=> ["adm", "staff", "root"],
			membership 	=> minimum,
			shell	 	=> "/bin/$shell",
			home 		=> "/home/$username",
			require 	=> [File["/etc/skel/.bash_profile"], Package[$shell]],
			password 	=> $password_hash,
		}

		if $ensure == "present" {
			kfile { "/home/$username":
				ensure => directory,
				mode 	=> 750,
				owner 	=> "$username",
				group 	=> "kumina",
				require => [User["$username"], Group["kumina"]],
			}

			kfile { "/home/$username/.ssh":
				ensure 	=> directory,
				mode 	=> 700,
				owner 	=> "$username",
				group 	=> "kumina",
				require => File["/home/$username"],
			}

			kfile { "/home/$username/.ssh/authorized_keys":
				ensure 	=> present,
				content => "$sshkeys",
				owner 	=> "$username",
				group 	=> "kumina",
				require => File["/home/$username"],
			}

			concat::add_content { "Add $username to Kumina SSH keyring":
				target  => "/etc/ssh/kumina.keys",
				content => "# $fullname <$username@kumina.nl>\n$sshkeys",
			}

			kfile { "/home/$username/.${shell}rc":
				ensure 	=> present,
				content => template("kbp_base/home/$username/.${shell}rc"),
				owner 	=> "$username",
				group 	=> "kumina",
				require => File["/home/$username"],
			}

			kfile { "/home/$username/.bash_profile":
				ensure 	=> present,
				source 	=> "kbp_base/home/$username/.bash_profile",
				owner 	=> "$username",
				group 	=> "kumina",
				require => File["/home/$username"],
			}

			kfile { "/home/$username/.bash_aliases":
				ensure 	=> present,
				source 	=> "kbp_base/home/$username/.bash_aliases",
				owner 	=> "$username",
				group 	=> "kumina",
				require => File["/home/$username"],
			}

			kfile { "/home/$username/.darcs":
				ensure => directory,
				mode 	=> 755,
				owner 	=> "$username",
				group 	=> "kumina",
				require => File["/home/$username"],
			}

			kfile { "/home/$username/.tmp":
				ensure => directory,
				mode 	=> 755,
				owner 	=> "$username",
				group 	=> "kumina",
				require => File["/home/$username"],
			}

			kfile { "/home/$username/.darcs/author":
				ensure => present,
				content => "$fullname <$username@kumina.nl>\n",
				group => "kumina",
				require => File["/home/$username/.darcs"],
			}

			kfile { "/home/$username/.gitconfig":
				ensure => present,
				content => template("kbp_base/git/.gitconfig"),
				group => "kumina";
			}

			kfile { "/home/$username/.reportbugrc":
				ensure => present,
				content => "REPORTBUGEMAIL=$username@kumina.nl\n",
				group => "kumina";
			}
		} else {
			kfile { "/home/$username":
				ensure  => absent,
				force   => true,
				recurse => true,
			}
		}
	}

	# Add the Kumina group and users
	# XXX Needs to do a groupmod when a group with gid already exists.
	group { "kumina":
		ensure => present,
		gid => 10000,
	}

	staff_user {
		"tim":
			fullname      => "Tim Stoop",
			uid           => 10001,
			password_hash => "BOGUS",
			sshkeys       => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCcRYiKZ1yPUU8+oRaDI/TyRSyFu2fwbknvr/Q3rwbQZm2K8iTfY4/WUeu/oSZOnCn5uoNjGax88RZx92DK0yYpOHtUwG/nShtTwte0Mx4zW8Sfq343OPle2b2gp/0V6dx1Nq21rmQrh0Ql23Thmi33cmKUvPgwYXvsIKfM68J2bG9+hIiucQX0AY7oH8UCX6uJmjOB2nPBsCMAmBHLsfV9LTvSobYAJLEt0m2wV+BqPZW5zLj7HyrGCDa5+85EB4MuQsiYuVdAjQJ3JF/FD0w7LrtuwhKZuS/Qwn4vXah1FlTBlIfw6IxWrQ0+CBCx4h/E4lbxgLTHCB4sanhUGKQtVV1/CFEA9GYCtDbNepFmjuZM1IubarpJmMicOebIW6yT9/035jKuS+nJG2xOLfV4MNPDkuAwqgg1DJ1JmqpG8y1+rHuswbXhlxlfKw/SEooH6I8NDv+TxHSkyo5siacNRsfQ8rQf9fKJdhD0twZuOZU8Zz9wpFz6VCYMkgKp05U= smartcard Tim Stoop\n";
		"kees":
			fullname      => "Kees Meijs",
			password_hash => "BOGUS",
			uid           => 10002,
			ensure        => absent;
		"mike":
			fullname      => "Mike Huijerjans",
			uid           => 10000,
			password_hash => "BOGUS",
			ensure        => absent;
		"pieter":
			fullname      => "Pieter Lexis",
			uid           => 10005,
			password_hash => "BOGUS",
			sshkeys       => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCitP9QOGYxCEqueFl/FC+K7o4hjA5zqG+oMirkqxE0EOX6VgwbigvIfzHnUI/LPkDCinhZGnFyfrTkvepcf6Bhtml3ex3lU2HvAiwVfrf/PWeNeg+MUYo7QGpqRUpC+qE82Epe8f0CLpwYo9Bzk4k4Toc1ZMvHUFzSOEBSe9tUetGmP7AGK/WDGJ5hc07XYV1/W3CAGO8XnhIS3/WdDS8D65iOXNQbwrndIfDn2Y3bWfd4qtx+KdY3+LU+6QKPS9Pdl5iYpWw3gln6NMoG8VDCaCNsr9qFNPOD26ninAGkzv31l59xIS94knutgCsov5KdxEWkd49m0ts5L+H9kZ+sznCr4I1Ng3CghABSU9gK7qnQbQR8PlM+eetyzrEFqHYApioyC2xAYJ+D6f65E7WadZBX5DZpqVEYZmw3d3rN49JI9DYlimUKA0Mu7KVfAURZ/3uir3HPZ0tBcyfqKEfT50Nqew92idjnoO191+lyvXXoiAc65EC/y5Ze8ZZ3pfU= pieter@kumina.nl\n";
		"rutger":
			fullname      => "Rutger Spiertz",
			uid           => 10003,
			password_hash => "BOGUS",
			sshkeys       => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCMZBz0sRqmfs4QT4dXVQeMIc+PdDChsjSUQv+SkN//z+igMw6qe5acC8EXUk5CR7VfaOjttp+sgoOxsvFPdFnrcozUsssnUynfVQ4GHCpDu0iOoUtz+WuGGonauAimhFsO2apkYLlO2qipt/z6B+bPQsbOxIVLpLLCa1kFKux7Td4vGddxbCxtFECd/4QUuS42G5q8nET3cdiqHM+QHXs1bnOqa6nxOxhnKX1jlqPT5nwdd8pI+RChGcjD4UofL9IYtz+Nd8wZi/h0tcOUh/ORV1bpJFwTCdWwaQ7Z7bf2Aanzn6iJz14nM0n19EOdvcB5NS/1mE54U9S3qJN+fQT3bOm47R07BIXmCEah6uZUAezkzsnXAsntgn2YDZFhjX+6Xd0iALAlhOyOMVfjJ0cq/qv1WhqScyOOETZhwOjLm4lewigpRnctJBt87p8MArPTBbJJA4TayC9eP6IfZ6plu0Be+W+xvrh/ga3oxMiyg6LWCf2yeTRUut7aIyswxY8= rutger@kumina.nl\n";
		"ed":
			fullname      => "Ed Schouten",
			uid           => 10004,
			password_hash => "BOGUS",
			shell         => "zsh",
			sshkeys       => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXah/YknMvN7CCOAK642FZfnXYVZ2uYZsy532v8pOISzH9W8mJ4FqBi0g1oAFhTZs0VNc9ouNfMDG178LSITL+ui/6T9exOEd4a0pCXuArVFmc5EVEUl3F+/qZPcOnWs7e3KaiV1dGLYDI0LhdG9ataHHR3sSPI/YAhroDLDTSVqFURXL7eyqR/aEv7nPEkY4zhQQzTECSQdadwEtGnovjNNL2aEj8rVVle5lVjbSk4N7x0ixyb4eTPB1z5FnwAlVkxHhTnsxTK28ulkrVCgKE30KS97dRG/EjA81pOzajRYTyLztqSkJnpKpL/lPfUCG7VkNfQKF+0O/KRhUfr2zb cardno:00050000057D\n";
	}

	# Packages we like and want :)
	kpackage {
		["bash","binutils","console-tools","realpath","zsh"]:
			ensure => installed;
		["hidesvn","bash-completion","bc","tcptraceroute","diffstat","host","whois","pwgen"]:
			ensure => latest;
	}

	# We run Ksplice, so always install the latest debian kernel
	include gen_base::linux-base
	class { "gen_base::linux-image":
		version => $kernelrelease;
	}

	if versioncmp($lsbdistrelease, 6.0) < 0 {
		kpackage { "tcptrack":
			ensure => latest,
		}
	}

	kfile {
		"/etc/motd.tail":
			source 	=> "kbp_base/motd.tail";
		"/etc/console-tools/config":
			source  => "kbp_base/console-tools/config",
			require => Package["console-tools"];
	}

	exec {
		"uname -snrvm | tee /var/run/motd ; cat /etc/motd.tail >> /var/run/motd":
			refreshonly => true,
			path => ["/usr/bin", "/bin"],
			require => File["/etc/motd.tail"],
			subscribe => File["/etc/motd.tail"];
	}
}

# Class: kbp_base::environment
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_base::environment {
	include kbp_monitoring::environment
	include kbp_user::environment

	@@kbp_smokeping::environment { "${environment}":; }

	kbp_smokeping::targetgroup { "${environment}":; }
}
