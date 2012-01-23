define kbp_mediawiki::site($basepath="/srv/www") {
  gen_mediawiki::site { "${basepath}/${name}":; }
}

define kbp_mediawiki::extension($site, $basepath="/srv/www", $extrapath="base/") {
  gen_mediawiki::extension { $name:
    sitepath  => "${basepath}/${site}",
    extrapath => $extrapath;
  }
}
