class kbp_trending {
}

class kbp_trending::puppetmaster ($method="munin") {
	case $method {
		"munin": { include kbp_munin::client::puppetmaster }
		default: { fail("No trending for ${method}.") }
	}
}

class kbp_trending::mysql ($method="munin") {
	case $method {
		"munin": { include kbp_munin::client::mysql }
		default: { fail("No trending for ${method}.") }
	}
}

class kbp_trending::nfs ($method="munin") {
	case $method {
		"munin": { include kbp_munin::client::nfs }
		default: { fail("No trending for ${method}.") }
	}
}

class kbp_trending::nfsd ($method="munin") {
	case $method {
		"munin": { include kbp_munin::client::nfsd }
		default: { fail("No trending for ${method}.") }
	}
}
