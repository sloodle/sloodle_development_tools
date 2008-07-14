#!/bin/sh
#
# Script to generate tarballs / zip files from SVN repository at Google.
# Expects the latest sloodle module directory to have been checked out once into                                              SVNROOT.
# Will update itself.
# Creates one tarball / zip per revision, and copies the latest to sloodle.tar.g                                             z / sloodle.zip
# (C) Edmund Edgar, 2007-09-09
# Licensed under the GPL v2 - see sloodle/COPYING for details.

ROOT=/var/www/download
RESOURCEROOT=${ROOT}/resources
WEBROOT=${ROOT}/webroot/sloodle
SVNROOT=${RESOURCEROOT}/svn/sloodle
CODEROOT=${RESOURCEROOT}/code

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

OLDREVISION=`${CAT} ${CODEROOT}/sloodle/REVISION`
REVISION=`${SVN} update ${SVNROOT} | ${GREP} 'At revision' | ${AWK} '{print $3}'                                              | $SED s/\\\\.//`
REVISION=r${REVISION}
echo $REVISION

if [[ ${OLDREVISION} != ${REVISION} ]]; then

        ${RSYNC} -arvz --delete ${SVNROOT}/ ${CODEROOT}/sloodle/ --exclude=".svn                                             "
        $ECHO ${REVISION} > ${CODEROOT}/sloodle/REVISION

        cd ${CODEROOT}
        ${TAR} zcvf ${WEBROOT}/sloodle.${REVISION}.tar.gz sloodle
        ${CP} ${WEBROOT}/sloodle.${REVISION}.tar.gz ${WEBROOT}/sloodle.tar.gz.te                                             mp
        ${MV} ${WEBROOT}/sloodle.tar.gz.temp ${WEBROOT}/sloodle.tar.gz
        #echo "${TAR} zcvf ${WEBROOT}/sloodle.${REVISION}tar.gz . -C ${CODEROOT}                                             "

        ${ZIP} ${WEBROOT}/sloodle.${REVISION}.zip -r sloodle/
        ${CP} ${WEBROOT}/sloodle.${REVISION}.zip ${WEBROOT}/sloodle.zip.temp
        ${MV} ${WEBROOT}/sloodle.zip.temp ${WEBROOT}/sloodle.zip

fi

