define kbp_pmacct::config ($aggregates_nfprobe=false, $aggregates=["src_host","dst_host"], $aggregates_sql=$aggregates, $filter=false, $plugins=["mysql"], $sql_host="localhost", $sql_db="pmacct", $sql_user="pmacct", $sql_passwd=false,
    $sql_history="5m", $sql_history_roundoff="m", $sql_refresh_time="300", $sql_dont_try_update=true, $nfprobe_version=9, $nfprobe_receiver=false) {
  include gen_base::python_mysqldb

  gen_pmacct::config { $name:
    aggregates_sql       => $aggregates_sql,
    aggregates_nfprobe   => $aggregates_nfprobe,
    filter               => $filter,
    plugins              => $plugins,
    sql_host             => $sql_host,
    sql_db               => $sql_db,
    sql_user             => $sql_user,
    sql_passwd           => $sql_passwd,
    sql_history          => $sql_history,
    sql_history_roundoff => $sql_history_roundoff,
    sql_refresh_time     => $sql_refresh_time,
    sql_dont_try_update  => $sql_dont_try_update,
    nfprobe_version      => $nfprobe_version,
    nfprobe_receiver     => $nfprobe_receiver,
  }

  if "mysql" in $plugins {
    kbp_mysql::client { "Client for pmacct":
      address => $source_ipaddress,
    }

    @@mysql::server::db { "${sql_db} for ${hostname}":
      tag => "mysql_${environment}_${custenv}";
    }

    @@mysql::server::grant { "${sql_user} on ${sql_db} for pmacct on ${hostname}":
      password => $sql_passwd,
      hostname => $source_ipaddress,
      tag      => "mysql_${environment}_${custenv}";
    }
  }

  # TODO Setup monitoring/trending
}
