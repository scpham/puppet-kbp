# Author: Kumina bv <support@kumina.nl>

# Class: kbp_logrotate
#
# Actions:
#  Setup logrotate the way we want it.
#
# Depends:
#  gen_logrotate
#
class kbp_logrotate {
  include gen_logrotate

  file { '/etc/logrotate.conf':
    content => template('kbp_logrotate/logrotate.conf'),
  }
}

# Class: kbp_logrotate::rotate
#
# Actions:
#  Add rotation to a file or multiple files.
#
# Parameters:
#  name: The name of the logrotate config file to create
#  logs: Defines which log file(s) to rotate
#  options: An array with the logrotate options, defaults to ["weekly","compress","rotate 7","missingok"]
#  prerotate: Defines a command to run before rotating the log. Defaults to false (no command).
#  postrotate: Defines a command to run after rotating the log. Defaults to false (no command).
#
define kbp_logrotate::rotate ($logs, $options=["weekly","compress","rotate 7","missingok"], $prerotate=false, $postrotate=false) {
  include kbp_logrotate

  gen_logrotate::rotate { $name:
    logs => $logs,
    options => $options,
    prerotate => $prerotate,
    postrotate => $postrotate,
  }
}
