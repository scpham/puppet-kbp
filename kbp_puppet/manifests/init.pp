class kbp_puppet {
	include gen_puppet

	gen_apt::preference { ["puppet","puppet-common"]:; }
}

class kbp_puppet::vim {
	include kbp_vim

	kbp_vim { "puppet":
		package => "vim-puppet",
	}
}
