define kbp_mediawiki::site {
  gen_mediawiki::site { $name:; }
}

define kbp_mediawiki::extension($sitepath, $extrapath="base/") {
  gen_mediawiki::extension { $name:
    sitepath  => $sitepath,
    extrapath => $extrapath;
  }
}
