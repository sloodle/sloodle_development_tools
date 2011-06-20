#!/bin/sh -x
# This is a script to take a Moodle <1.9 install and make it work on Moodle >=2.0
# Copyright Edmund Edgar, 2011-06-20
# Licensed under the same terms as Sloodle itself.

if test $# -eq 0
then
	echo "Usage: php migrate.php /path/to/sloodle/top/dir";
	exit 1
fi

THIS_DIR=$(cd `dirname $0` && pwd)
APPLY_TO=$1

echo "applying to ${APPLY_TO}"
echo "applying from ${THIS_DIR}"

cd ${APPLY_TO}

# Replace legacy Moodle functions with sloodle_ wrappers
find . -type f ! -regex ".*[/]\.svn[/]?.*" -exec sed -f ${THIS_DIR}/sloodle_wrappers.sed -i {} \;

# Patch various misc changes, including the new wrapper functions
patch -p1 < ${THIS_DIR}/sloodle.patch

# Rename the language directories to drop the utf8 
for x in `ls -d lang/*_utf8 | sed 's/_utf8$//' `; do mv ${x}_utf8 $x; done
