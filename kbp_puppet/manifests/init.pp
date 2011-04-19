class kbp_puppet {
	include gen_puppet

	gen_apt::preference { ["puppet","puppet-common"]:; }
}
