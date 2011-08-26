#!/bin/sh
if [ -z $1 -o -z $2 ]; then
	echo "specify jira root directory and version" >&2
	exit 1
fi


SOURCE_DIR="${1}/source"
JIRA_URL="http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-${2}-war.tar.gz"

TARNAME="`basename $JIRA_URL`"

cleandir() {
	find $SOURCE_DIR -mindepth 2 -delete || $(echo "could not clean $SOURCE_DIR" >&2; exit 2)
}

downloadtar() {
	/usr/bin/wget -O $SOURCE_DIR/$TARNAME -o $SOURCE_DIR/wget.log $JIRA_URL
	if [ $? != 0 ]; then
		echo "The download went awry, please see ${SOURCE_DIR}/wget.log" >&2
		exit 1
	fi
	rm ${SOURCE_DIR}/wget.log
}

check_sum() {
	echo "`cat ${SOURCE_DIR}/${TARNAME}.md5`  $SOURCE_DIR/$TARNAME" | /usr/bin/md5sum -c --status
}

# Create the source dir if it doesn't exist
/usr/bin/test -d $SOURCE_DIR || mkdir -p $SOURCE_DIR
/usr/bin/test -f $SOURCE_DIR/DOWNLOADED_$2 && rm $SOURCE_DIR/DOWNLOADED_$2


# Get the MD5SUM
/usr/bin/test -f $SOURCE_DIR/${TARNAME}.md5 && rm $SOURCE_DIR/${TARNAME}.md5
/usr/bin/wget -O $SOURCE_DIR/${TARNAME}.md5 -o $SOURCE_DIR/wget.log ${JIRA_URL}.md5
if [ $? != 0 ]; then
	echo "The download went awry, please see $SOURCE_DIR/wget.log" >&2
	exit 1
fi
rm $SOURCE_DIR/wget.log

# Download the TAR if it doesn't exist
if [ ! -f $SOURCE_DIR/$TARNAME ]; then
	downloadtar
fi

# Check is the MD5SUM matches
check_sum
if [ $? != 0 ]; then
	rm $SOURCE_DIR/$TARNAME
	downloadtar
	check_sum
	if [ $? != 0 ]; then
		echo "MD5 sums don't match" >&2
		exit 1
	fi
fi

# clean the atlassian-jira directory
cleandir
/bin/tar xzf $SOURCE_DIR/$TARNAME -C $SOURCE_DIR 2>&1 > $SOURCE_DIR/tar.log

if [ $? != 0 ]; then
	echo "Could not untar, check $SOURCE_DIR/tar.log" >&2
	cleandir
	exit 1
fi
rm $SOURCE_DIR/tar.log

find $SOURCE_DIR -mindepth 1 -maxdepth 1 -type d -name "*war*" -exec mv {}/ $SOURCE_DIR/atlassian_jira \; 2> $SOURCE_DIR/find.log
if [ $? != 0 ]; then
	echo "Something when wrong with moving see $SOURCE_DIR/find.log" >&2
	cleandir
	exit 1
fi

rm $SOURCE_DIR/find.log
touch $SOURCE_DIR/DOWNLOADED_${2}
exit 0
