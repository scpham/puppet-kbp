#!/bin/sh
# fix_wp_permissions - A script that finds and fixes permissions in
# WordPress installations
#
# Copyright 2013 - Kumina B.V.
# Licensed under the terms of the GNU GPL version 3 or higher

if [ $(id -u) -ne 0 ]; then
	echo "Please run ${0} as root." >&2
	exit 1
fi

usage() {
	echo "Usage: $0 <PATH|all>" >&2
	echo "  PATH is the path to the directory containing the WordPress" >&2
	echo "  installation. e.g. '/srv/www/myblog.mysite.com'." >&2
	echo "  When supplying 'all', ALL subdirectories of /srv/www are checked" >&2
	echo "  for WordPress installations and all wp-content/uploads and " >&2
	echo "  wp-content/blogs.dir directories and file therein will be " >&2
	echo "  chowned to www-data." >&2
	exit 1
}

do_chown() {
	P=$(/usr/bin/realpath $1)
	case $P in
		/srv/www/*)
			if [ -f $P/wp-config.php -a -d $P/wp-content/uploads ]; then # This is a WordPress directory
				/usr/bin/find -P $P/wp-content/uploads \( -type d -or -type f \) -not -user www-data -exec /bin/chown -h www-data {} +
				/usr/bin/find -P $P/wp-content/uploads -type d -not -perm -u=rwx -exec /bin/chown u=rwx {} +
				/usr/bin/find -P $P/wp-content/uploads -type f -not -perm -u=rw -exec /bin/chmod u=rw {} +
				if [ -d $P/wp-content/blogs.dir ]; then # We also have multi-site
					/usr/bin/find -P $P/wp-content/blogs.dir \( -type d -or -type f \) -not -user www-data -exec /bin/chown -h www-data {} +
					/usr/bin/find -P $P/wp-content/blogs.dir -type d -not -perm -u=rwx -exec /bin/chmod u=rwx {} +
					/usr/bin/find -P $P/wp-content/blogs.dir -type f -not -perm -u=rw -exec /bin/chmod u=rw {} +
				fi
			else
				if [ $2 ]; then # if the dir is not a WP directory AND it was supplied by the user
					echo "Error: ${1} does not appear to be a WordPress site." >&2
					exit 2
				fi
			fi
			;;
		*)
			echo "Error: $1 is not a subdirectory of /srv/www, refusing to continue." >&2
			echo "Please contact support@kumina.nl if you want to change permissions on files." >&2
			exit 3
			;;
	esac
}

if [ -z $1 ]; then
	usage
elif [ $# -ne 1 ]; then
	usage
elif [ $1 = '-h' -o $1 = '--help' -o $1 = '-u' -o $1 = '--usage' ]; then
	usage
fi

if [ $1 = 'all' ]; then
	for x in /srv/www/*; do
		do_chown $x
	done
	exit 0
else
	if [ -d $1 ]; then
		do_chown $1 X
		exit 0
	else
		echo "Error: ${1} is not a directory."
		exit 4
	fi
fi
