# Define: kbp_mail
#
# Actions:
#  Set up mail
#
# Parameters:
#  certs           The Puppet location and name (without extension) of the certificates for Dovecot. Only used and has to be set when mode is primary
#  deploycerts     Set to false if certificate is deployed elsewhere (default: true)
#  relayhost       Same as Postfix, see http://www.postfix.org/postconf.5.html#relayhost. Absent by default
#  mailname        The name to set in /etc/mailname. Defaults to $fqdn
#  mydomain        The domain to use for sending emails. Defaults to $domain
#  mydestination   Same as Postfix, see http://www.postfix.org/postconf.5.html#mydestination. Defaults to $fqdn, $hostname, localhost.localdomain, localhost. The default is appended when this param is set
#  accept_incoming Set to true to allow the server to accept incoming mail. Defaults to false
#  myhostname      Same as Postfix, see http://www.postfix.org/postconf.5.html#myhostname. Defaults to $fqdn
#  mynetworks      Same as Postfix, see http://www.postfix.org/postconf.5.html#mynetworks. Defaults to 127.0.0.0/8 [::1]/128
#  always_bcc      Same as Postfix, see http://www.postfix.org/postconf.5.html#always_bcc. Absent by default
#  mode            Set to primary for a full mailserver, secondary for a backup mailserver, false otherwise. Defaults to false
#                  Special mode: 'dovecot': configure everything as primary, except postfix which will be configured with mode=false
#  mysql_user      The MySQL username used for Postfix and Dovecot. Only used and has to be set when mode is primary
#  mysql_pass      The MySQL password used for Postfix and Dovecot. Only used and has to be set when mode is primary
#  mysql_db        The MySQL database used for Postfix and Dovecot. Only used and has to be set when mode is primary
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
define kbp_mail($certs=false, $deploycerts=true, $relayhost=false, $mailname=false, $mydestination=false, $accept_incoming=false, $myhostname=false, $mynetworks=false,
    $always_bcc=false, $mode=false, $mysql_user='mailserver', $mysql_pass=false, $mysql_db='mailserver', $relay_domains=false, $mydomain=$domain,
    $postmaster=false, $monitor_username=false, $monitor_password=false) {
  if $mode == 'primary' or $mode == 'secondary' or $mode == 'dovecot' {
    include gen_postgrey

    if $mode == 'primary' or $mode == 'dovecot' {
      if !defined(Class["kbp_mysql::server"]) {
        include kbp_mysql::server
      }

      file {
        ['/usr/local','/usr/local/share','/usr/local/share/mail']:
          ensure => directory,
          owner  => undef,
          group  => undef,
          mode   => undef;
        '/usr/local/share/mail/mailserver-tables.sql':
          content => template('kbp_mail/mailserver-tables.sql');
      }

      mysql::server::grant { "${mysql_user} on ${mysql_db}":
        hostname => '127.0.0.1',
        password => $mysql_pass,
        notify   => Exec['create-mailserver-tables'];
      }

      exec { 'create-mailserver-tables':
        refreshonly => true,
        command     => "/usr/bin/mysql -u ${mysql_user} -p{$mysql_pass} ${mysql_db} < /usr/local/share/mail/mailserver-tables.sql",
        require     => [File['/usr/local/share/mail/mailserver-tables.sql'], Mysql::Server::Grant["${mysql_user} on ${mysql_db}"]];
      }

      if ! $certs {
        fail('When using primary or dovecot mode for kbp_mail, $certs must be set as dovecot and postfix need it.')
      }
      if ! $postmaster {
        fail('When using primary or dovecot mode for kbp_mail, $postmaster must be set as dovecot needs it.')
      }
      if ! $monitor_username {
        fail('When using primary or dovecot mode for kbp_mail, $monitor_username must be set as dovecot needs it.')
      }
      if ! $monitor_password {
        fail('When using primary or dovecot mode for kbp_mail, $monitor_password must be set as dovecot needs it.')
      }

      include kbp_amavis
      class { 'kbp_dovecot::imap':
        certs            => $certs,
        deploycerts      => $deploycerts,
        postmaster       => $postmaster,
        mysql_user       => $mysql_user,
        mysql_pass       => $mysql_pass,
        mysql_db         => $mysql_db,
        mysql_host       => '127.0.0.1',
        monitor_username => $monitor_username,
        monitor_password => $monitor_password;
      }
    }
  }

  class { 'kbp_postfix':
    certs         => $certs,
    relayhost     => $relayhost,
    mailname      => $mailname,
    mydomain      => $mydomain,
    mydestination => $mydestination,
    myhostname    => $myhostname,
    mynetworks    => $mynetworks,
    always_bcc    => $always_bcc,
    mode          => $mode ? {
      'dovecot' => false,
      default   => $mode,
    },
    mysql_user    => $mysql_user,
    mysql_pass    => $mysql_pass,
    mysql_db      => $mysql_db,
    mysql_host    => '127.0.0.1',
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
