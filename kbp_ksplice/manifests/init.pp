define kbp_ksplice($ensure=true) {
  include gen_base::python_pycurl
  if $ensure {
    include ksplice
  }
}
