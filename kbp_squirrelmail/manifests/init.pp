class kbp_squirrelmail {
  include gen_squirrelmail
}

define kbp_squirrelmail::site ($ssl=false, $intermediate=false, $redirect_non_ssl=false, $address=false, $serveralias=false, $org_name=false, $org_logo=false, $org_logo_width=false, $org_logo_height=false, $org_title=false, $provider_uri=false) {
  include kbp_squirrelmail

  kbp_apache::site { $name:
    ssl                 => $ssl,
    intermediate        => $intermediate,
    redirect_non_ssl    => $redirect_non_ssl,
    address             => $address,
    serveralias         => $serveralias,
    documentroot        => '/usr/share/squirrelmail',
    create_documentroot => false,
    php                 => true;
  }

  file {
    "/etc/squirrelmail/config_local.php":
      content => template("kbp_squirrelmail/config_local.php"),
      require => Package["squirrelmail"];
  }
}
