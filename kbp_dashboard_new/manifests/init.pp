class kbp_dashboard_new::server($url, $ssl=true) {
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
      content => template("kbp_dashboard_new/style.css");
    "/srv/www/${url}/.htpasswd":
      ensure  => link,
      target  => "/srv/www/${url}/kumina/.htpasswd",
      require => Kfile["/srv/www/${url}"];
  }

  concat { "/srv/www/${url}/index.html":
    require => Kfile["/srv/www/${url}"];
  }

  concat::add_content {
    "0 index.html base head for kumina_new":
      content => template("kbp_dashboard/index.html_base_head"),
      target  => "/srv/www/${url}/index.html";
    "2 index.html base tail for kumina_new":
      content => template("kbp_dashboard/index.html_customer_tail"),
      target  => "/srv/www/${url}/index.html";
  }

  Kbp_dashboard_new::Environment <<| |>>
  Kbp_dashboard_new::Customer_entry <<| |>>
  Kbp_dashboard_new::Base_entry <<| |>>
  Kbp_dashboard_new::Server_base <<| |>> {
    url => $url,
  }
  Kbp_dashboard_new::Server_interface <<| |>> {
    url => $url,
  }
}

class kbp_dashboard_new::client {
  @@kbp_dashboard_new::server_base { $fqdn:
    environment => $environment,
    parent      => $parent,
    fqdn        => $fqdn,
    proccount   => $processorcount,
    memsize     => $memorysize;
  }

  $used_ifs_string = template("kbp_dashboard_new/interfaces")
  $used_ifs = split($used_ifs_string, ",")

  kbp_dashboard_new::server_interface::wrapper { $used_ifs:; }
}

define kbp_dashboard_new::environment($fullname) {
  kfile {
    "/srv/www/${url}/${name}":
      ensure  => directory,
      purge   => true,
      recurse => true,
      force   => true;
    "/srv/www/${url}/${name}/style.css":
      content => template("kbp_dashboard_new/style.css");
    "/srv/www/${url}/${name}/overview":
      ensure  => directory,
      purge   => true,
      recurse => true,
      force   => true;
    "/srv/www/${url}/${name}/overview/servers":
      ensure  => directory,
      purge   => true,
      recurse => true,
      force   => true;
  }

  concat {
    "/srv/www/${url}/${name}/index.html":
      require => Kfile["/srv/www/${url}/${name}"];
    "/srv/www/${url}/${name}/.htpasswd":
      require => Kfile["/srv/www/${url}/${name}"];
  }

  concat::add_content {
    "0 index.html customer head for ${name}_new":
      content => template("kbp_dashboard_new/index.html_customer_head"),
      target  => "/srv/www/${url}/${name}/index.html";
    "2 index.html customer tail for ${name}_new":
      content => template("kbp_dashboard_new/index.html_customer_tail"),
      target  => "/srv/www/${url}/${name}/index.html";
    "1 index.html base body for ${name}_new":
      content => template("kbp_dashboard_new/index.html_base_body"),
      target  => "/srv/www/${url}/index.html";
  }

  Concat::Add_content <<| tag == "htpasswd_${name}" |>> {
    target => "/srv/www/${url}/${name}/.htpasswd",
  }

  kbp_apache_new::vhost_addition { "${url}_${port}/access_${name}":
    content => template("kbp_dashboard_new/vhost-additions/access");
  }

  @@kbp_dashboard_new::base_entry { "Overview for ${name}":
    path        => "overview",
    text        => "Machine overview",
    entry_name  => "Overview",
    environment => $name;
  }
}

define kbp_dashboard_new::customer_entry_export($path, $extra_paths=false, $regex_paths=false, $entry_url, $text, $add_environment=true) {
  $entry_name = regsubst($name,'^(.*?) (.*)$','\1')

  if ! defined(Kbp_dashboard_new::Customer_entry["${entry_name}_${environment}"]) {
    @@kbp_dashboard_new::customer_entry { "${entry_name}_${environment}":
      path            => $path,
      extra_paths     => $extra_paths,
      regex_paths     => $regex_paths,
      entry_url       => $entry_url,
      text            => $text,
      add_environment => $add_environment,
      entry_name      => $entry_name,
      environment     => $environment;
    }
  }
}

define kbp_dashboard_new::customer_entry($path, $extra_paths=false, $regex_paths=false, $entry_url, $text, $add_environment=true, $entry_name, $environment) {
  $base_path = $path

  concat::add_content { "1 index.html content for ${entry_name} for ${environment}":
    content => template("kbp_dashboard_new/index.html_customer_body"),
    target  => "/srv/www/${url}/${environment}/index.html";
  }

  kbp_apache_new::vhost_addition { "${url}_${port}/proxy_${entry_name}_${environment}":
    content => template("kbp_dashboard_new/vhost-additions/proxy");
  }
}

define kbp_dashboard_new::base_entry($path, $text, $entry_name, $environment) {
  $base_path = $path

  concat::add_content { "1 index.html content for ${entry_name} for ${environment}_new":
    content => template("kbp_dashboard_new/index.html_customer_body"),
    target  => "/srv/www/${url}/${environment}/index.html";
  }
}

define kbp_dashboard_new::server_base($environment, $parent=false, $fqdn, $proccount, $memsize, $url=false) {
  kfile { "/srv/www/${url}/${environment}/overview/servers/${fqdn}.xml":; }

  kaugeas { $name:
    file    => "/srv/www/${url}/${environment}/overview/servers/${fqdn}.xml",
    lens    => "Xml.lns",
    changes => ["set server/fqdn '${name}'",
                "set server/parent '${parent}'",
                "set server/proccount '${proccount}'",
                "set server/memsize '${memsize}'"],
    require => Kfile["/srv/www/${url}/${environment}/overview/servers/${fqdn}.xml"];
  }
}

define kbp_dashboard_new::server_interface($environment, $fqdn, $interface, $ipv4, $ipv6, $mac, $url=false) {
  kaugeas { $name:
    file    => "/srv/www/${url}/${environment}/overview/servers/${fqdn}.xml",
    lens    => "Xml.lns",
    changes => ["set server/interface '${interface}'",
                "set server/interface/${interface}/ipv4 '${ipv4}'",
                "set server/interface/${interface}/ipv6 '${ipv6}'",
                "set server/interface/${interface}/mac '${mac}'"],
    require => Kfile["/srv/www/${url}/${environment}/overview/servers/${fqdn}.xml"];
  }
}

define kbp_dashboard_new::server_interface::wrapper() {
  $interface = $name

  @@kbp_dashboard_new::server_interface { "${interface}_${fqdn}":
    environment => $environment,
    fqdn        => $fqdn,
    interface   => $interface,
    ipv4        => template("kbp_dashboard_new/ipv4"),
    ipv6        => template("kbp_dashboard_new/ipv6"),
    mac         => template("kbp_dashboard_new/mac");
  }
}
