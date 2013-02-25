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
	echo "Usage: $0 [-g|--group GROUP] <PATH|all>" >&2
	echo "  PATH  is the path to the directory containing the WordPress" >&2
	echo "        installation. e.g. '/srv/www/myblog.mysite.com'. When" >&2
	echo "        supplying 'all', ALL subdirectories of /srv/www are checked" >&2
	echo "        for WordPress installations and all wp-content/uploads and " >&2
	echo "        wp-content/blogs.dir directories and files therein will be " >&2
	echo "        chowned to www-data." >&2
	echo "  GROUP is an optional group name to chgrp the WP installation to." >&2
	exit 1
}

do_chown() {
	P=$(/usr/bin/realpath $1)
	case $P in
		/srv/www/*)
			if [ -f $P/wp-config.php -a -d $P/wp-content/uploads ]; then # This is a WordPress directory
				/usr/bin/find -P $P/wp-content/uploads \( -type d -or -type f \) -not -user www-data -exec /bin/chown -h www-data {} +
				/usr/bin/find -P $P/wp-content/uploads -type d -not -perm -u=rwx -exec /bin/chmod u=rwx {} +
				/usr/bin/find -P $P/wp-content/uploads -type f -not -perm -u=rw -exec /bin/chmod u=rw {} +
				if [ ! -z $GROUP ]; then
					/usr/bin/find -P $P/wp-content/uploads \( -type d -or -type f \) -not -group $GROUP -exec /bin/chgrp -h $GROUP {} +
					/usr/bin/find -P $P/wp-content/uploads -type d -not -perm -g=rwx -exec /bin/chmod g=rwx {} +
					/usr/bin/find -P $P/wp-content/uploads -type f -not -perm -g=rw -exec /bin/chmod g=rw {} +
				fi
				if [ -d $P/wp-content/blogs.dir ]; then # We also have multi-site
					/usr/bin/find -P $P/wp-content/blogs.dir \( -type d -or -type f \) -not -user www-data -exec /bin/chown -h www-data {} +
					/usr/bin/find -P $P/wp-content/blogs.dir -type d -not -perm -u=rwx -exec /bin/chmod u=rwx {} +
					/usr/bin/find -P $P/wp-content/blogs.dir -type f -not -perm -u=rw -exec /bin/chmod u=rw {} +
					if [ ! -z $GROUP ]; then
						/usr/bin/find -P $P/wp-content/blogs.dir \( -type d -or -type f \) -not -group $GROUP -exec /bin/chgrp -h $GROUP {} +
						/usr/bin/find -P $P/wp-content/blogs.dir -type d -not -perm -g=rwx -exec /bin/chmod g=rwx {} +
						/usr/bin/find -P $P/wp-content/blogs.dir -type f -not -perm -g=rw -exec /bin/chmod g=rw {} +
					fi
				fi
			else
				if [ $2 ]; then # if the dir is not a WP directory AND it was supplied by the user
					echo "Error: ${1} does not appear to be a WordPress site." >&2
					exit 2
				fi
			fi
			;;
		*)
			echo "Error: ${1} is not a subdirectory of /srv/www, refusing to continue." >&2
			echo "Please contact support@kumina.nl if you want to change permissions on files." >&2
			exit 3
			;;
	esac
}

# Have getopt parse the arguments
ARGS=`/usr/bin/getopt -o g:hu -l group:,help,usage -n $0 -- "$@"`

if [ $? -ne 0 ]; then # If something went wrong
	echo "" >&2
	usage
fi

eval set -- "$ARGS"

GROUP=''
while true; do
	case "$1" in
		-g|--group) GROUP=$2; shift 2;;
		-h|--help|-u|--usage) usage;;
		--) shift; break;;
		*) exit 1;;
	esac
done

# is a directory supplied?
if [ -z $1 ]; then
	usage
fi

# check if the user is indeed in the group
if [ ! -z $GROUP ]; then
	# XXX this code assumes we're run using sudo
	if $(id -G -n $SUDO_USER | grep -v -q $GROUP); then # The user isn't in the group $GROUP
		if $(id -G -n $SUDO_USER | grep -v -q kumina); then # The user is also not in the group kumina
			echo "You (${SUDO_USER}) are not in the group ${GROUP}, refusing to continue." >&2
			exit 4
		fi
	fi
fi

if [ $1 = 'all' ]; then
	for x in /srv/www/*; do
		do_chown $x
	done
	exit 0
else
	if [ -d $1 ]; then
		do_chown $1
		exit 0
	else
		echo "Error: ${1} is not a directory." >&2
		exit 5
	fi
fi
