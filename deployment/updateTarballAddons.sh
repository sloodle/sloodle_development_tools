#!/bin/sh
# 
# Script to generate tarballs / zip files from SVN repository at Google.
# Expects the latest sloodle module directory to have been checked out once into SVNROOT.
# Will update itself.
# Creates one tarball / zip per revision, and copies the latest to sloodle.tar.gz / sloodle.zip
# (C) Edmund Edgar, 2009-08-13
# Licensed under the GPL v3 - see sloodle/COPYING for details.

ROOT=/var/www/download
RESOURCEROOT=${ROOT}/resources
WEBROOT=${ROOT}/webroot/sloodle/latest
SVNROOT=${RESOURCEROOT}/svnaddons/addons
CODEROOT=${RESOURCEROOT}/codeaddons/addons
SLOODLETOPDIR=addons

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

OLDREVISION=`${CAT} ${CODEROOT}/REVISION`
REVISION=`${SVN} update ${SVNROOT} | ${GREP} 'At revision' | ${AWK} '{print $3}' | $SED s/\\\\.//`
REVISION=r${REVISION}
echo $REVISION

if [[ ${OLDREVISION} != ${REVISION} ]]; then

	${RSYNC} -arvz --delete ${SVNROOT}/ ${CODEROOT}/ --exclude=".svn"
	$ECHO ${REVISION} > ${CODEROOT}/REVISION

	cd ${CODEROOT}
	cd ..
	${TAR} zcvf ${WEBROOT}/${SLOODLETOPDIR}.${REVISION}.tar.gz ${SLOODLETOPDIR}
#	${CP} ${WEBROOT}/${SLOODLETOPDIR}.${REVISION}.tar.gz ${WEBROOT}/${SLOODLETOPDIR}.tar.gz.temp
#	${MV} ${WEBROOT}/${SLOODLETOPDIR}.tar.gz.temp ${WEBROOT}/${SLOODLETOPDIR}.tar.gz
	${MV} ${WEBROOT}/${SLOODLETOPDIR}.${REVISION}.tar.gz ${WEBROOT}/${SLOODLETOPDIR}.tar.gz

	${ZIP} ${WEBROOT}/${SLOODLETOPDIR}.${REVISION}.zip -r ${SLOODLETOPDIR}/
#	${CP} ${WEBROOT}/${SLOODLETOPDIR}.${REVISION}.zip ${WEBROOT}/${SLOODLETOPDIR}.zip.temp
#	${MV} ${WEBROOT}/${SLOODLETOPDIR}.zip.temp ${WEBROOT}/${SLOODLETOPDIR}.zip
	${MV} ${WEBROOT}/${SLOODLETOPDIR}.${REVISION}.zip ${WEBROOT}/${SLOODLETOPDIR}.zip

fi
