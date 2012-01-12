class kbp_django {
  include gen_django

  kfile { "/srv/django":
    ensure => directory;
  }

  kbp_apache_new::module { "python":; }
}
