class kbp_noc::server($domain="dashboard.kumina.nl") {
  Kbp_noc::Environment <<| |>>

  kbp_apache_new::site { $domain:
    auth         => true,
    documentroot => "/srv/www/${domain}",
    serveralias  => false,
    make_default => $make_default;
  }

  kfile {
    "/srv/www/${domain}/style.css":
      content => template("kbp_noc/style.css");
    "/srv/www/${domain}/.htpasswd":
      ensure  => link,
      target  => "/srv/www/${domain}/kumina/.htpasswd",
      require => Kfile["/srv/www/${domain}"];
  }

  concat {
    "/srv/www/${domain}/index.html":
      require => Kfile["/srv/www/${domain}"];
  }

  concat::add_content {
    "0 index.html base head for kumina":
      content => template("kbp_noc/index.html_base_head"),
      target  => "/srv/www/${domain}/index.html";
    "2 index.html base tail for kumina":
      content => template("kbp_noc/index.html_customer_tail"),
      target  => "/srv/www/${domain}/index.html";
  }

  Kbp_noc::Customer_entry <<| |>>
}

define kbp_noc::environment($fullname) {
  kfile {
    "/srv/www/${domain}/${name}":
      ensure  => directory;
    "/srv/www/${domain}/${name}/style.css":
      content => template("kbp_noc/style.css");
  }

  concat {
    "/srv/www/${domain}/${name}/index.html":
      require => Kfile["/srv/www/${domain}/${name}"];
    "/srv/www/${domain}/${name}/.htpasswd":
      require => Kfile["/srv/www/${domain}/${name}"];
  }

  concat::add_content {
    "0 index.html customer head for ${name}":
      content => template("kbp_noc/index.html_customer_head"),
      target  => "/srv/www/${domain}/${name}/index.html";
    "2 index.html customer tail for ${name}":
      content => template("kbp_noc/index.html_customer_tail"),
      target  => "/srv/www/${domain}/${name}/index.html";
    "1 index.html base body for ${name}":
      content => template("kbp_noc/index.html_base_body"),
      target  => "/srv/www/${domain}/index.html";
  }

  Concat::Add_content <<| tag == "htpasswd_${name}" |>> {
    target => "/srv/www/${domain}/${name}/.htpasswd",
  }

  kbp_apache_new::vhost_addition { "${domain}_80/access_${name}":
    content => template("kbp_noc/vhost-additions/access");
  }
}

define kbp_noc::customer_entry_export($path, $extra_paths=false, $regex_paths=false, $url, $text, $add_environment=true) {
  @@kbp_noc::customer_entry { "${name}_${environment}":
    path            => $path,
    extra_paths     => $extra_paths,
    regex_paths     => $regex_paths,
    url             => $url,
    text            => $text,
    add_environment => $add_environment,
    entry_name      => $name,
    environment     => $environment;
  }
}

define kbp_noc::customer_entry($path, $extra_paths=false, $regex_paths=false, $url, $text, $add_environment=true, $entry_name, $environment) {
  $base_path = $path

  concat::add_content { "1 index.html content for ${entry_name} for ${environment}":
    content => template("kbp_noc/index.html_customer_body"),
    target  => "/srv/www/${domain}/${environment}/index.html";
  }

  kbp_apache_new::vhost_addition { "${domain}_80/proxy_${entry_name}_${environment}":
    content => template("kbp_noc/vhost-additions/proxy");
  }
}
