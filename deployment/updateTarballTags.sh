#!/bin/sh
# 
# Script to generate tarballs / zip files from SVN repository at Google.
# Expects the latest sloodle module directory to have been checked out once into SVNROOT.
# Will update itself.
# Creates one tarball / zip per revision, and copies the latest to sloodle.tar.gz / sloodle.zip
# (C) Edmund Edgar, 2007-09-09
# Licensed under the GPL v2 - see sloodle/COPYING for details.

ROOT=/var/www/download
WEBROOT=${ROOT}/webroot/sloodle # This should be a web-accessible directory where we're going to put the tarballs
RESOURCEROOT=${ROOT}/resources # Temporary files and things all go under here - should be outside the webroot
SVNROOT=${RESOURCEROOT}/svntags # You need to have checked out the tags directory to here
CODEROOT=${RESOURCEROOT}/codetags # This will be for copies of the code without the .svn stuff.

SVN=/usr/bin/svn
AWK=/bin/awk
GREP=/bin/grep
RSYNC=/usr/bin/rsync
TAR=/bin/tar
MV=/bin/mv
CP=/bin/cp
SED=/bin/sed
ECHO=/bin/echo
ZIP="/usr/bin/zip -q"
CAT=/bin/cat

${SVN} update ${SVNROOT} 

cd ${SVNROOT}

for tag in `ls`
do
	echo ${tag}
	if [ ! -f ${WEBROOT}/sloodle_all_${tag}.zip ]; # haven't done this one yet
	then
		${RSYNC} -arz --delete ${SVNROOT}/${tag}/ ${CODEROOT}/${tag}/ --exclude=".svn"

		cd ${CODEROOT}/${tag}
		${TAR} zcf ${WEBROOT}/sloodle_menu_${tag}.tar.gz sloodle_menu
		${TAR} zcf ${WEBROOT}/sloodle_${tag}.tar.gz sloodle
		${TAR} zcf ${WEBROOT}/sloodleobject_${tag}.tar.gz sloodleobject
		${TAR} zcf ${WEBROOT}/sloodle_all_${tag}.tar.gz .

		${ZIP} ${WEBROOT}/sloodle_menu_${tag}.zip -r sloodle_menu
		${ZIP} ${WEBROOT}/sloodle_${tag}.zip -r sloodle
		${ZIP} ${WEBROOT}/sloodleobject_${tag}.zip -r sloodleobject
		${ZIP} ${WEBROOT}/sloodle_all_${tag}.zip -r .

		#${CP} ${WEBROOT}/sloodle.${REVISION}.tar.gz ${WEBROOT}/sloodle.tar.gz.temp
		#${MV} ${WEBROOT}/sloodle.tar.gz.temp ${WEBROOT}/sloodle.tar.gz
		#echo "${TAR} zcvf ${WEBROOT}/sloodle.${REVISION}tar.gz . -C ${CODEROOT}"
	fi
done
