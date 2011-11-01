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

  exec {
    "/bin/echo 'kernel.panic = 30' >> '/etc/sysctl.conf'":
      unless => "/bin/grep -Fx 'kernel.panic = 30' /etc/sysctl.conf";
    "/bin/echo 'kernel.panic_on_oops = 1' >> '/etc/sysctl.conf'":
      unless => "/bin/grep -Fx 'kernel.panic_on_oops = 1' /etc/sysctl.conf";
  }
}
