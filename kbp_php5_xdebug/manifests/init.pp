class kbp_php5_xdebug {
  include gen_php5::common

  if $lsbmajdistrelease > 5 {
    $file_location = "/usr/lib/php5/20090626/xdebug.so"
  } else {
    $file_location = "/usr/lib/php5/20060613/xdebug.so"
  }

  package { "php5-xdebug":
    ensure => latest;
  }

  file { "/etc/php5/conf.d/xdebug.ini":
    content => "zend_extension=${file_location}\nxdebug.remote_enable=On\nhtml_errors=On\n",
    require => Package["php5-common"],
    notify  => Exec["reload-apache2"];
  }
}
