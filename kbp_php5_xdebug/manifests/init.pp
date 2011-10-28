class gen_php5_xdebug {
	kpackage { "php5-xdebug":
		ensure => latest;
	}

	kfile { "/etc/php5/conf.d/xdebug.ini":
		content => $lsbmajdistrelease > 5 ? {
			true  => "zend_extension=/usr/lib/php5/20090626/xdebug.so\nxdebug.remote_enable=On\nhtml_errors=On\n",
			false => "zend_extension=/usr/lib/php5/20060613/xdebug.so\nxdebug.remote_enable=On\nhtml_errors=On\n",
		},
		notify  => Exec["reload-apache2"];
	}
}
