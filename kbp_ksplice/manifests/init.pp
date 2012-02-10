define kbp_ksplice($ensure=true) {
  include gen_base::libcurl3_gnutls
  if $ensure {
    include ksplice
  }
}
