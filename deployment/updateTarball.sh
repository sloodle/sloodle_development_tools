#!/bin/sh
# 
# Script to generate tarballs / zip files from SVN repository at Google.
# Expects the latest sloodle module directory to have been checked out once into SVNROOT.
# Will update itself.
# Creates one tarball / zip per revision, and copies the latest to sloodle.tar.gz / sloodle.zip
# (C) Edmund Edgar, 2007-09-09
# Licensed under the GPL v2 - see sloodle/COPYING for details.

ROOT=/var/www/download
RESOURCEROOT=${ROOT}/resources
WEBROOT=${ROOT}/webroot/sloodle/latest
SVNROOT=${RESOURCEROOT}/svn
CODEROOT=${RESOURCEROOT}/code
SLOODLETOPDIR=sloodle_all
IARROOT=$SVNROOT/$SLOODLETOPDIR/iar
URLROOT=http://download.socialminds.jp/sloodle/latest

SVN=/usr/bin/svn
AWK=/bin/awk
GREP=/bin/grep
RSYNC=/usr/bin/rsync
TAR=/bin/tar
MV=/bin/mv
CP=/bin/cp
SED=/bin/sed
ECHO=/bin/echo
ZIP=/usr/bin/zip -q
CAT=/bin/cat

OLDREVISION=`${CAT} ${CODEROOT}/${SLOODLETOPDIR}/sloodle/REVISION`
REVISION=`${SVN} update ${SVNROOT}/${SLOODLETOPDIR} | ${GREP} 'At revision' | ${AWK} '{print $3}' | $SED s/\\\\.//`
REVISION=r${REVISION}

if [[ ${OLDREVISION} != ${REVISION} ]]; then

	echo "Creating trunk tarball for revision $REVISION"

	${RSYNC} -arz --delete ${SVNROOT}/ ${CODEROOT}/ --exclude=".svn" --exclude=".iar"
	$ECHO ${REVISION} > ${CODEROOT}/${SLOODLETOPDIR}/sloodle/REVISION

	cd ${CODEROOT}
	${TAR} zcf ${WEBROOT}/${SLOODLETOPDIR}.${REVISION}.tar.gz ${SLOODLETOPDIR}

#	${CP} ${WEBROOT}/${SLOODLETOPDIR}.${REVISION}.tar.gz ${WEBROOT}/${SLOODLETOPDIR}.tar.gz.temp
#	${MV} ${WEBROOT}/${SLOODLETOPDIR}.tar.gz.temp ${WEBROOT}/${SLOODLETOPDIR}.tar.gz
	${MV} ${WEBROOT}/${SLOODLETOPDIR}.${REVISION}.tar.gz ${WEBROOT}/${SLOODLETOPDIR}.tar.gz
	echo "Updated ${URLROOT}/${SLOODLETOPDIR}.tar.gz"

	${ZIP} ${WEBROOT}/${SLOODLETOPDIR}.${REVISION}.zip -r ${SLOODLETOPDIR}/
#	${CP} ${WEBROOT}/${SLOODLETOPDIR}.${REVISION}.zip ${WEBROOT}/${SLOODLETOPDIR}.zip.temp
#	${MV} ${WEBROOT}/${SLOODLETOPDIR}.zip.temp ${WEBROOT}/${SLOODLETOPDIR}.zip
	${MV} ${WEBROOT}/${SLOODLETOPDIR}.${REVISION}.zip ${WEBROOT}/${SLOODLETOPDIR}.zip
	echo "Updated ${URLROOT}/${SLOODLETOPDIR}.zip"

	cd $IARROOT
	${TAR} zcf ${WEBROOT}/development.${REVISION}.iar * --exclude=".svn"
	${MV} ${WEBROOT}/development.${REVISION}.iar ${WEBROOT}/development.iar
	echo "Updated ${URLROOT}/development.iar"

fi
