#!/bin/sh
#
# Script to generate a tarball / zip file based on a tag from git.
# (C) Edmund Edgar, 2011-0831-
# Licensed under the GPL v2 - see sloodle/COPYING for details.

TAR=/bin/tar
ZIP="/usr/bin/zip -q"
SLOODLETOPDIR=moodle_wwwroot



if [ "$1" = "" ]; then
   echo "Usage: sloodle_development_tools/deployment/make_tarball.sh <tag> <location>"
   exit
fi

if [ "$2" = "" ]; then
   echo "Usage: sloodle_development_tools/deployment/make_tarball.sh <tag> <location>"
   exit
fi


echo $TAG;

if [ ! -d sloodle_development_tools ]; then
   echo "The tag_release script must be run from inside the sloodle_all_submodules directory."
   exit
fi

TAG=$1
SAVEDIR=$2
echo "Updating to version $TAG"
git checkout $TAG

echo "Updating submodules"
git submodule init
git submodule update

echo "Creating tarball and zip for tag $TAG"

${TAR} zcf "${SAVEDIR}/sloodle_${TAG}.tar.gz" ${SLOODLETOPDIR}/
${ZIP} "${SAVEDIR}/sloodle_${TAG}.zip" -r ${SLOODLETOPDIR}/


