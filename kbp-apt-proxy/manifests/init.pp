class kbp-apt-proxy inherits approx {
	Kfile["/etc/approx/approx.conf"] {
		source => "kbp-apt-proxy/approx/approx.conf",
	}
}
