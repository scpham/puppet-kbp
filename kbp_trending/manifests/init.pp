class kbp_trending {
}

class kbp_trending::puppetmaster ($method="munin") {
	case $method {
		"munin": { include kbp_munin::client::puppetmaster }
		default: { err("No trending for ${method}.") }
	}
}

class kbp_trending::mysql ($method="munin") {
	case $method {
		"munin": { include kbp_munin::client::mysql }
		default: { err("No trending for ${method}.") }
	}
}

class kbp_trending::nfs ($method="munin") {
	case $method {
		"munin": { include kbp_munin::client::nfs }
		default: { err("No trending for ${method}.") }
	}
}
