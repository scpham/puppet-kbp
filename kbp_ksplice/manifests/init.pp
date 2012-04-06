define kbp_ksplice($ensure=true) {
  include gen_base::python_pycurl
  if $ensure {
    include ksplice
  }
  include kbp_icinga::ksplice
}

define kbp_ksplice::proxy ($proxy) {
  ksplice::proxy { $name:
    proxy => $proxy;
  }
}
