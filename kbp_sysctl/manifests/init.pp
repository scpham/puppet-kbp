# Author: Kumina bv <support@kumina.nl>

# Class: kbp_sysctl
#
# Actions:
#  Undocumented
#
# Depends:
#  sysctl
#  gen_puppet
#
class kbp_sysctl {
  include sysctl

  sysctl::setting {
    'kernel.panic':
      value => 30;
    'kernel.panic_on_oops':
      value => 1;
  }
}
