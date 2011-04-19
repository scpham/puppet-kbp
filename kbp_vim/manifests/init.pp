class kbp_vim {
	include gen_vim

	gen_vim::global_setting {
		"syntax on":;
		"set ai":;
		"set ts=8":;
		"set bg=dark":;
		"set list":;
		"set listchars=tab:»˙,trail:•":;
		"set hlsearch":;
		"set ruler":;
		"set backupdir=~/.tmp/":
			require => Global_vim_setting['silent execute "!mkdir -p ~/.tmp"'];
		"set directory=~/.tmp/":
			require => Global_vim_setting['silent execute "!mkdir -p ~/.tmp"'];
		'silent execute "!mkdir -p ~/.tmp"':;
	}
}

class kbp_vim::puppet {
	include gen_vim

	gen_vim::addon { "puppet":
		package => "vim-puppet",
	}
}
