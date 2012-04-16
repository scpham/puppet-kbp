class kbp_django {
  include gen_django
  include gen_base::libapache2-mod-wsgi

  file { "/srv/django":
    ensure => directory;
  }

  kbp_apache_new::module { "wsgi":
    require => Kpackage["libapache2-mod-wsgi"];
  }
}
