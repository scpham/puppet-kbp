class kbp_kvm {
	include gen_kvm

	# Enable KSM
	exec { "/bin/echo 1 > /sys/kernel/mm/ksm/run":
		onlyif => "/usr/bin/test `cat /sys/kernel/mm/ksm/run` == 0",
	}
}
