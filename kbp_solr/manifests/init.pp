# Author: Kumina bv <support@kumina.nl>

# Class: kbp_solr
#
# Actions:
#  Basic setup of Solr
#
# Depends:
#  gen_puppet
#
class kbp_solr ($tomcat_tag="tomcat_solr_${environment}"){
  include gen_solr

  class { "kbp_tomcat":
    tomcat_tag => $tomcat_tag;
  }

  kbp_tomcat::webapp { "solr":
    urlpath                     => "/solr",
    war                         => "/usr/share/solr",
    additional_context_settings => { "debug" => "0", "privileged" => "true", "crossContext" => "true", "allowLinking" => "true" },
    environment_settings        => { "solr/home" => { "var_type" => "java.lang.String", "value" => "/usr/share/solr" } },
    tomcat_tag                  => $tomcat_tag;
  }

  # Setup the ability to use symlinks
  kaugeas { "Context resource to allow sym-linking for solr":
    file    => "/srv/tomcat/conf/Catalina/localhost/solr.xml",
    lens    => "Xml.lns",
    changes => ["set Context/Resources[#attribute/className='org.apache.naming.resources.FileDirContext']/#attribute/className 'org.apache.naming.resources.FileDirContext'",
                "set Context/Resources[#attribute/className='org.apache.naming.resources.FileDirContext']/#attribute/allowLinking 'true'"],
    notify  => Service["tomcat6"],
    require => File["/srv/tomcat/conf/Catalina/localhost/solr.xml"];
  }

  # Set the correct permissions on the data store
  file { "/var/lib/solr/data":
    owner   => "tomcat6",
    require => Package["tomcat6","solr-common"],
    notify  => Service["tomcat6"],
  }

  Kbp_ferm::Rule <<| tag == "solr_monitoring" |>>

  kbp_dashboard::service::wrapper { 'solr':; }
}
