class kbp_django {
  include gen_django
  include gen_base::libapache2-mod-wsgi

  kfile { "/srv/django":
    ensure => directory;
  }

  kbp_apache_new::module { ["python","wsgi"]:; }
}
