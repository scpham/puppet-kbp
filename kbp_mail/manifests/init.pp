# Define: kbp_mail
#
# Actions:
#  Set up mail
#
# Parameters:
#  certs           The Puppet location and name (without extension) of the certificates for Dovecot. Only used and has to be set when mode is primary
#  relayhost       Same as Postfix, see http://www.postfix.org/postconf.5.html#relayhost. Absent by default
#  mailname        The name to set in /etc/mailname. Defaults to $fqdn
#  mydestination   Same as Postfix, see http://www.postfix.org/postconf.5.html#mydestination. Defaults to $fqdn, $hostname, localhost.localdomain, localhost. The default is appended when this param is set
#  accept_incoming Set to true to allow the server to accept incoming mail. Defaults to false
#  myhostname      Same as Postfix, see http://www.postfix.org/postconf.5.html#myhostname. Defaults to $fqdn
#  mynetworks      Same as Postfix, see http://www.postfix.org/postconf.5.html#mynetworks. Defaults to 127.0.0.0/8 [::1]/128
#  always_bcc      Same as Postfix, see http://www.postfix.org/postconf.5.html#always_bcc. Absent by default
#  mode            Set to primary for a full mailserver, secondary for a backup mailserver, false otherwise. Defaults to false
#  mysql_user      The MySQL username used for Postfix and Dovecot. Only used and has to be set when mode is primary
#  mysql_pass      The MySQL password used for Postfix and Dovecot. Only used and has to be set when mode is primary
#  mysql_db        The MySQL database used for Postfix and Dovecot. Only used and has to be set when mode is primary
#  mysql_host      The MySQL host used for Postfix and Dovecot. Only used and has to be set when mode is primary
#  relay_domains   Same as Postfix, see http://www.postfix.org/postconf.5.html#relay_domains. Only used when mode is primary or secondary. Defaults to false (which means '$mydestination' in Postfix)
#  postmaster      Email address of postmaster (used by Dovecot)
#
# Depends:
#  gen_postgrey (only when mode is primary or secondary)
#  kbp_amavis (only when mode is primary)
#  kbp_dovecot (only when mode is primary)
#  kbp_postfix
#  kbp_ferm (only accept_incoming is true or mode is primary or secondary)
#
define kbp_mail($certs=false, $relayhost=false, $mailname=false, $mydestination=false, $accept_incoming=false, $myhostname=false, $mynetworks=false,
    $always_bcc=false, $mode=false, $mysql_user=false, $mysql_pass=false, $mysql_db=false, $mysql_host=false, $relay_domains=false,
    $postmaster=false) {
  if $mode == 'primary' or $mode == 'secondary' {
    include gen_postgrey

    if $mode == 'primary' {
      if ! $certs {
        fail('When using primary mode for kbp_mail, $certs must be set as dovecot and postfix need it.')
      }

      if ! $postmaster {
        fail('When using primary mode for kbp_mail, $postmaster must be set as dovecot needs it.')
      }

      include kbp_amavis
      class { 'kbp_dovecot::imap':
        certs      => $certs,
        postmaster => $postmaster,
        mysql_user => $mysql_user,
        mysql_pass => $mysql_pass,
        mysql_db   => $mysql_db,
        mysql_host => $mysql_host;
      }
    }
  }

  class { 'kbp_postfix':
    certs         => $certs,
    relayhost     => $relayhost,
    mailname      => $mailname,
    mydestination => $mydestination,
    myhostname    => $myhostname,
    mynetworks    => $mynetworks,
    always_bcc    => $always_bcc,
    mode          => $mode,
    mysql_user    => $mysql_user,
    mysql_pass    => $mysql_pass,
    mysql_db      => $mysql_db,
    mysql_host    => $mysql_host,
    relay_domains => $relay_domains;
  }

  if $accept_incoming or $mode == 'primary' or $mode == 'secondary' {
    kbp_ferm::rule { 'SMTP connections':
      proto  => 'tcp',
      dport  => '(25 465)',
      action => 'ACCEPT';
    }
  }
}
