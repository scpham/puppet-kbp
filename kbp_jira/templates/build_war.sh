#!/bin/sh
if [ -z $1 ]; then
	echo "specify jira root directory" >&2
	exit 1
fi

SOURCE_DIR="${1}/source"
JIRA_DIR=$SOURCE_DIR/atlassian_jira

cd $JIRA_DIR

/usr/bin/ant 2>&1 > $SOURCE_DIR/build.log

if [ $? != 0 ]; then
	echo "An ant error has occured, please check $SOURCE_DIR/build.log for more information" >&2
	exit 1
fi
rm $SOURCE_DIR/build.log

# Build succeeded, replace the current war with the new one
#find $SOURCE_DIR -mindepth 1 -maxdepth 1 -name "*.war" -delete
#mv $JIRA_DIR/dist-tomcat/tomcat-6/*.war $SOURCE_DIR/atlassian-jira.war
exit 0
