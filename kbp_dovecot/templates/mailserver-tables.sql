CREATE TABLE `mail_aliases` (
  `address` text COLLATE utf8_unicode_ci NOT NULL,
  `destination` text COLLATE utf8_unicode_ci NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `mail_domains` (
  `domain` text COLLATE utf8_unicode_ci NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `mail_users` (
  `address` text COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `maildir` text COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`address`(50))
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
