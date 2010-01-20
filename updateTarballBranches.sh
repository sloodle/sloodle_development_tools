#!/bin/sh -x
# 
# Script to generate tarballs / zip files from SVN repository at Google.
# Expects the latest sloodle module directory to have been checked out once into SVNROOT.
# Will update itself.
# Creates one tarball / zip per revision, and copies the latest to sloodle.tar.gz / sloodle.zip
# (C) Edmund Edgar, 2007-09-09
# Licensed under the GPL v2 - see sloodle/COPYING for details.

ROOT=/var/www/download
WEBROOT=${ROOT}/webroot/sloodle/branches # This should be a web-accessible directory where we're going to put the tarballs
RESOURCEROOT=${ROOT}/resources # Temporary files and things all go under here - should be outside the webroot
SVNROOT=${RESOURCEROOT}/svnbranches # You need to have checked out the tags directory to here
CODEROOT=${RESOURCEROOT}/codebranches # This will be for copies of the code without the .svn stuff.

SVN=/usr/bin/svn
AWK=/bin/awk
GREP=/bin/grep
RSYNC=/usr/bin/rsync
TAR=/bin/tar
MV=/bin/mv
CP=/bin/cp
SED=/bin/sed
ECHO=/bin/echo
ZIP=/usr/bin/zip
CAT=/bin/cat

${SVN} update ${SVNROOT} 

cd ${SVNROOT}

for tag in `ls`
do
	echo ${tag}
	if [ ! -f ${WEBROOT}/sloodle_all_${tag}.zip ]; # haven't done this one yet
	then
		${RSYNC} -arvz --delete ${SVNROOT}/${tag}/ ${CODEROOT}/${tag}/ --exclude=".svn"

		cd ${CODEROOT}/${tag}
		${TAR} zcvf ${WEBROOT}/sloodle_menu_${tag}.tar.gz sloodle_menu
		${TAR} zcvf ${WEBROOT}/sloodle_${tag}.tar.gz sloodle
		${TAR} zcvf ${WEBROOT}/sloodleobject_${tag}.tar.gz sloodleobject
		${TAR} zcvf ${WEBROOT}/sloodle_all_${tag}.tar.gz .

		${ZIP} ${WEBROOT}/sloodle_menu_${tag}.zip -r sloodle_menu
		${ZIP} ${WEBROOT}/sloodle_${tag}.zip -r sloodle
		${ZIP} ${WEBROOT}/sloodleobject_${tag}.zip -r sloodleobject
		${ZIP} ${WEBROOT}/sloodle_all_${tag}.zip -r .

		#${CP} ${WEBROOT}/sloodle.${REVISION}.tar.gz ${WEBROOT}/sloodle.tar.gz.temp
		#${MV} ${WEBROOT}/sloodle.tar.gz.temp ${WEBROOT}/sloodle.tar.gz
		#echo "${TAR} zcvf ${WEBROOT}/sloodle.${REVISION}tar.gz . -C ${CODEROOT}"
	else
		if [ `find ${SVNROOT}/${tag}/  -path '*/.svn' -prune -o  -newer ${WEBROOT}/sloodle_all_${tag}.zip -type f -print | wc -l` -gt 0 ]
		then
			echo "Updating $tag"
			${RSYNC} -arvz --delete ${SVNROOT}/${tag}/ ${CODEROOT}/${tag}/ --exclude=".svn"

			cd ${CODEROOT}/${tag}
			${TAR} zcvf ${WEBROOT}/sloodle_menu_${tag}.tar.gz.temp sloodle_menu
			${TAR} zcvf ${WEBROOT}/sloodle_${tag}.tar.gz.temp sloodle
			${TAR} zcvf ${WEBROOT}/sloodleobject_${tag}.tar.gz.temp sloodleobject
			${TAR} zcvf ${WEBROOT}/sloodle_all_${tag}.tar.gz.temp .

			${ZIP} ${WEBROOT}/sloodle_menu_${tag}.zip.temp -r sloodle_menu
			${ZIP} ${WEBROOT}/sloodle_${tag}.zip.temp -r sloodle
			${ZIP} ${WEBROOT}/sloodleobject_${tag}.zip.temp -r sloodleobject
			${ZIP} ${WEBROOT}/sloodle_all_${tag}.zip.temp -r .

			${MV} ${WEBROOT}/sloodle_menu_${tag}.tar.gz.temp ${WEBROOT}/sloodle_menu_${tag}.tar.gz
			${MV} ${WEBROOT}/sloodle_${tag}.tar.gz.temp ${WEBROOT}/sloodle_${tag}.tar.gz
			${MV} ${WEBROOT}/sloodleobject_${tag}.tar.gz.temp ${WEBROOT}/sloodleobject_${tag}.tar.gz
			${MV} ${WEBROOT}/sloodle_all_${tag}.tar.gz.temp ${WEBROOT}/sloodle_all_${tag}.tar.gz

			${MV} ${WEBROOT}/sloodle_menu_${tag}.zip.temp ${WEBROOT}/sloodle_menu_${tag}.zip
			${MV} ${WEBROOT}/sloodle_${tag}.zip.temp ${WEBROOT}/sloodle_${tag}.zip
			${MV} ${WEBROOT}/sloodleobject_${tag}.zip.temp ${WEBROOT}/sloodleobject_${tag}.zip
			${MV} ${WEBROOT}/sloodle_all_${tag}.zip.temp ${WEBROOT}/sloodle_all_${tag}.zip

		fi
	fi
done
