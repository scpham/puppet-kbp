class kbp_dashboard::server($url, $ssl=true) {
  $port = $ssl ? {
    false => 80,
    true  => 443,
  }

  kfile {
    "/srv/www/${url}":
      ensure  => directory,
      purge   => true,
      recurse => true,
      force   => true;
    "/srv/www/${url}/style.css":
      content => template("kbp_dashboard/style.css");
    "/srv/www/${url}/.htpasswd":
      ensure  => link,
      target  => "/srv/www/${url}/kumina/.htpasswd",
      require => Kfile["/srv/www/${url}"];
  }

  concat { "/srv/www/${url}/index.html":
    require => Kfile["/srv/www/${url}"];
  }

  concat::add_content {
    "0 index.html base head for kumina":
      content => template("kbp_dashboard/index.html_base_head"),
      target  => "/srv/www/${url}/index.html";
    "2 index.html base tail for kumina":
      content => template("kbp_dashboard/index.html_customer_tail"),
      target  => "/srv/www/${url}/index.html";
  }

  Kbp_dashboard::Environment <<| |>>
  Kbp_dashboard::Customer_entry <<| |>>
  Kbp_dashboard::Base_entry <<| |>>
  Kbp_dashboard::Overview_entry_host <<| |>> {
    url  => $url,
  }
  Kbp_dashboard::Overview_entry_vm <<| |>> {
    url  => $url,
  }
}

class kbp_dashboard::client {
  if $is_virtual == "false" {
    $resource_name = "1 index.html overview body for ${fqdn}"

    @@kbp_dashboard::overview_entry_host { $fqdn:
      resource_name => $resource_name,
      environment   => $environment,
      content       => template("kbp_dashboard/index.html_overview_body");
    }
  } else {
    $resource_name        = "1 index.html overview body for ${parent} 1 ${fqdn}"
    $parent_resource_name = "1 index.html overview body for ${parent}"

    @@kbp_dashboard::overview_entry_vm { $fqdn:
      resource_name        => $resource_name,
      environment          => $environment,
      parent               => $parent,
      parent_resource_name => $parent_resource_name,
      content              => template("kbp_dashboard/index.html_overview_body");
    }
  }
}

define kbp_dashboard::environment($fullname) {
  kfile {
    "/srv/www/${url}/${name}":
      ensure  => directory,
      purge   => true,
      recurse => true,
      force   => true;
    "/srv/www/${url}/${name}/style.css":
      content => template("kbp_dashboard/style.css");
    "/srv/www/${url}/${name}/overview":
      ensure  => directory,
      purge   => true,
      recurse => true,
      force   => true;
    "/srv/www/${url}/${name}/overview/style.css":
      content => template("kbp_dashboard/style.css_overview");
  }

  concat {
    "/srv/www/${url}/${name}/index.html":
      require => Kfile["/srv/www/${url}/${name}"];
    "/srv/www/${url}/${name}/.htpasswd":
      require => Kfile["/srv/www/${url}/${name}"];
    "/srv/www/${url}/${name}/overview/index.html":
      require => Kfile["/srv/www/${url}/${name}"];
  }

  concat::add_content {
    "0 index.html customer head for ${name}":
      content => template("kbp_dashboard/index.html_customer_head"),
      target  => "/srv/www/${url}/${name}/index.html";
    "2 index.html customer tail for ${name}":
      content => template("kbp_dashboard/index.html_customer_tail"),
      target  => "/srv/www/${url}/${name}/index.html";
    "1 index.html base body for ${name}":
      content => template("kbp_dashboard/index.html_base_body"),
      target  => "/srv/www/${url}/index.html";
    "0 index.html overview head for ${name}":
      content => template("kbp_dashboard/index.html_overview_head"),
      target  => "/srv/www/${url}/${name}/overview/index.html";
    "2 index.html overview tail for ${name}":
      content => template("kbp_dashboard/index.html_overview_tail"),
      target  => "/srv/www/${url}/${name}/overview/index.html";
  }

  Concat::Add_content <<| tag == "htpasswd_${name}" |>> {
    target => "/srv/www/${url}/${name}/.htpasswd",
  }

  kbp_apache_new::vhost_addition { "${url}_${port}/access_${name}":
    content => template("kbp_dashboard/vhost-additions/access");
  }

  @@kbp_dashboard::base_entry { "Overview for ${name}":
    path        => "overview",
    text        => "Machine overview",
    entry_name  => "Overview",
    environment => $name;
  }
}

define kbp_dashboard::customer_entry_export($path, $extra_paths=false, $regex_paths=false, $entry_url, $text, $add_environment=true) {
  $entry_name = regsubst($name,'^(.*) (.*?)$','\1')

  if ! defined(Kbp_dashboard::Customer_entry["${entry_name}_${environment}"]) {
    @@kbp_dashboard::customer_entry { "${entry_name}_${environment}":
      path            => $path,
      extra_paths     => $extra_paths,
      regex_paths     => $regex_paths,
      entry_url       => $entry_url,
      text            => $text,
      add_environment => $add_environment,
      entry_name      => $name,
      environment     => $environment;
    }
  }
}

define kbp_dashboard::customer_entry($path, $extra_paths=false, $regex_paths=false, $entry_url, $text, $add_environment=true, $entry_name, $environment) {
  $base_path = $path

  concat::add_content { "1 index.html content for ${entry_name} for ${environment}":
    content => template("kbp_dashboard/index.html_customer_body"),
    target  => "/srv/www/${url}/${environment}/index.html";
  }

  kbp_apache_new::vhost_addition { "${url}_${port}/proxy_${entry_name}_${environment}":
    content => template("kbp_dashboard/vhost-additions/proxy");
  }
}

define kbp_dashboard::base_entry($path, $text, $entry_name, $environment) {
  $base_path = $path

  concat::add_content { "1 index.html content for ${entry_name} for ${environment}":
    content => template("kbp_dashboard/index.html_customer_body"),
    target  => "/srv/www/${url}/${environment}/index.html";
  }
}

define kbp_dashboard::overview_entry_host($resource_name, $content, $environment, $parent=false, $url=false) {
  if defined(Concat::Add_content["${resource_name} 0 ${environment}"]) {
    Concat::Add_content <| title == "${resource_name} 0 ${environment}" |> {
      content => $content,
    }
  } else {
    concat::add_content { "${resource_name} 0 ${environment}":
      content => $content,
      target  => "/srv/www/${url}/${environment}/overview/index.html";
    }
  }
}

define kbp_dashboard::overview_entry_vm($resource_name, $content, $environment, $parent=false, $parent_resource_name=false, $url=false) {
  if $parent and ! defined(Concat::Add_content["${parent_resource_name} 0 ${environment}"]) {
    concat::add_content { "${parent_resource_name} 0 ${environment}":
      content => template("kbp_dashboard/index.html_overview_body_parent"),
      target  => "/srv/www/${url}/${environment}/overview/index.html";
    }
  }

  concat::add_content { $resource_name:
    content => $content,
    target  => "/srv/www/${url}/${environment}/overview/index.html";
  }
}
