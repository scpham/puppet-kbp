define kbp_pmacct::config ($aggregates, $plugins = ["mysql"], $sql_host = "localhost", $sql_db = "pmacct", $sql_user = "pmacct", $sql_passwd = false,
                           $sql_history = "5m", $sql_history_roundoff = "m", $sql_refresh_time = "300", $sql_dont_try_update = true,
                           $mysql_name = "pmacct") {
  gen_pmacct::config { $name:
    aggregates           => $aggregates,
    plugins              => $plugins,
    sql_host             => $sql_host,
    sql_db               => $sql_db,
    sql_user             => $sql_user,
    sql_passwd           => $sql_passwd,
    sql_history          => $sql_history,
    sql_history_roundoff => $sql_history_roundoff,
    sql_refresh_time     => $sql_refresh_time,
    sql_dont_try_update  => $sql_dont_try_update,
  }

  if "mysql" in $plugins {
    # TODO Should be source_ipaddress?
    kbp_mysql::client { "Client for pmacct":
      mysql_name => $mysql_name,
      address    => $ipaddress,
    }

    @@mysql::server::db { $sql_db:
      tag => "mysql_${environment}_${mysql_name}",
    }

    # TODO Should be source_ipaddress?
    @@mysql::server::grant { "${sql_user} on ${sql_db} for pmacct":
      password => $sql_passwd,
      hostname => $ipaddress,
      tag      => "mysql_${environment}_${mysql_name}",
    }
  }

  # TODO Setup monitoring/trending
}
