class kbp_django {
  include gen_django
  include gen_base::libapache2-mod-wsgi
  include gen_base::libjs_jquery

  file { "/srv/django":
    ensure => directory;
  }

  kbp_apache_new::module { "wsgi":
    require => Package["libapache2-mod-wsgi"];
  }
}
