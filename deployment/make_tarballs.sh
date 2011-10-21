#!/bin/sh
#
# Script to generate a tarball / zip file based on a tag from git.
# (C) Edmund Edgar, 2011-0831-
# Licensed under the GPL v2 - see sloodle/COPYING for details.

TAR=/bin/tar
ZIP="/usr/bin/zip -q"
SLOODLETOPDIR=moodle_wwwroot

if [ "$1" = "" ]; then
   echo "Usage: sloodle_development_tools/deployment/make_tarball.sh <tag> <working_dir> <location>"
   exit
fi

if [ "$2" = "" ]; then
   echo "Usage: sloodle_development_tools/deployment/make_tarball.sh <tag> <working_dir> <location>"
   exit
fi

if [ "$3" = "" ]; then
   echo "Usage: sloodle_development_tools/deployment/make_tarball.sh <tag> <working_dir> <location>"
   exit
fi

echo $TAG;

TAG=$1
WORKINGDIR=$2
SAVEDIR=$3

if [ -d "$WORKINGDIR" ]; then
   echo "Error: Working directory $WORKINGDIR already exists, exiting."
   exit
else
   mkdir "$WORKINGDIR"
fi

echo "Creating tarball and zip for tag $TAG"
mkdir "$WORKINGDIR/$SLOODLETOPDIR"
cd "$WORKINGDIR/$SLOODLETOPDIR"

# Everything goes under moodle_wwwroot

# The module goes under mod/sloodle
mkdir mod
cd mod
wget -O "$TAG.tar.gz" "https://github.com/sloodle/moodle-mod_sloodle/tarball/$TAG"
tar zxvf "$TAG.tar.gz"
rm "$TAG.tar.gz"
mv sloodle-moodle-* sloodle
cd ..

# The two blocks go under blocks/



mkdir blocks
cd blocks

wget -O "$TAG.tar.gz" "https://github.com/sloodle/moodle-block_sloodle_menu/tarball/$TAG"
tar zxvf "$TAG.tar.gz"
rm "TAG.tar.gz"
mv sloodle-moodle-* sloodle_menu

wget -O "$TAG.tar.gz" "https://github.com/sloodle/moodle-block_sloodle_backpack/tarball/$TAG"
tar zxvf "$TAG.tar.gz"
rm "$TAG.tar.gz"
mv sloodle-moodle-* sloodle_backpack

cd ..

# The assignment plugin goes under mod/assignment/type

mkdir mod/assignment
mkdir mod/assignment/type
cd mod/assignment/type

wget -O "$TAG.tar.gz" "https://github.com/sloodle/moodle-assignment_sloodleobject/tarball/$TAG"
tar zxvf "$TAG.tar.gz"
rm "$TAG.tar.gz"
mv sloodle-moodle-* sloodleobject

cd ../../..

cd ..
${TAR} zcf "${SAVEDIR}/sloodle_${TAG}.tar.gz" ${SLOODLETOPDIR}/
${ZIP} "${SAVEDIR}/sloodle_${TAG}.zip" -r ${SLOODLETOPDIR}/

cd ..
rm -rf "${WORKINGDIR}"
