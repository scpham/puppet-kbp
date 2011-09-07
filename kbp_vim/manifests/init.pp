# Author: Kumina bv <support@kumina.nl>

# Class: kbp_vim
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_vim {
	gen_vim::global_setting {
		"syntax on":;
		"set ai":;
		"set ts=8":;
		"set bg=dark":;
		"set list":;
		"set listchars=tab:»˙,trail:•":;
		"set hlsearch":;
		"set ruler":;
		'silent execute "!mkdir -p ~/.tmp"':;
		["set backupdir=~/.tmp/","set directory=~/.tmp/"]:
			require => Gen_vim::Global_setting['silent execute "!mkdir -p ~/.tmp"'];
		"autocmd FileType python set tabstop=4":;
		"autocmd FileType python set shiftwidth=4":;
		"autocmd FileType python set expandtab":;
	}
}

# Class: kbp_vim::puppet
#
# Actions:
#	Undocumented
#
# Depends:
#	Undocumented
#	gen_puppet
#
class kbp_vim::puppet {
	gen_vim::addon { "puppet":
		package => "vim-puppet";
	}
}
