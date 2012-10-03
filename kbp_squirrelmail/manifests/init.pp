class kbp_squirrelmail {
  include gen_squirrelmail
}

define kbp_squirrelmail::site ($ssl=false, $redirect_non_ssl=false, $org_name=false, $org_logo=false, $org_logo_width=false, $org_logo_height=false, $org_title=false, $provider_uri=false) {
  include kbp_squirrelmail

  kbp_apache::site { $name:
    ssl                 => $ssl,
    redirect_non_ssl    => $redirect_non_ssl,
    documentroot        => '/usr/share/squirrelmail',
    create_documentroot => false,
    php                 => true;
  }

  file {
    # set these php values globally for now
    "/etc/php5/conf.d/squirrelmail.ini":
      content => "upload_max_filesize=8M\npost_max_size=8M\n",
      require => Package['php5-common'],
      notify  => Exec["reload-apache2"];
    "/etc/squirrelmail/config_local.php":
      content => template("kbp_squirrelmail/config_local.php"),
      require => Package["squirrelmail"];
  }
}
