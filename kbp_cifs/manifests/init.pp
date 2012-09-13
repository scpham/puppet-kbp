# Author: Kumina bv <support@kumina.nl>

# Define: kbp_cifs::mount
#
# Actions:
#  Mount CIFS share from remote server
#
# Parameters:
#   name
#    Mountpoint
#   ensure
#    Same values as mount resource (http://docs.puppetlabs.com/references/stable/type.html#mount), default 'mounted'
#   unc
#    Uniform Naming Convention (http://en.wikipedia.org/wiki/Path_%28computing%29#Uniform_Naming_Convention), e.g. //servername/sharename/foo
#   options
#    Mount options, default 'rw'
#   username
#    CIFS username
#   password
#    CIFS password
#   domain
#    CIFS domain
#
# Depends:
#  gen_cifs
#
define kbp_cifs::mount($ensure='mounted', $unc, $options='rw', $username, $password, $domain) {
  gen_cifs::mount { $name:
    ensure   => $ensure,
    unc      => $unc,
    options  => $options,
    username => $username,
    password => $password,
    domain   => $domain;
  }
}
