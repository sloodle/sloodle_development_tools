#!/bin/sh
TAG=$1
WORKINGDIR=$2

if [ "$1" = "" ]; then
   echo "Usage: ../sloodle_development_tools/deployment/tag_release.sh <tag> <working_dir>"
   exit
fi

if [ "$2" = "" ]; then
   echo "Usage: ../sloodle_development_tools/deployment/tag_release.sh <tag> <working_dir>"
   exit
fi

echo $TAG;

mkdir $WORKINGDIR
cd $WORKINGDIR

REPOS="moodle-mod_sloodle moodle-assignment_sloodleobject moodle-block_sloodle_menu moodle-block_sloodle_backpack"
for REPO in $REPOS
do
	FULLREPO="git@github.com:sloodle/${REPO}.git"
	git clone $FULLREPO 
	cd $REPO
	git pull
	git tag $TAG
	git push --tags
	cd ..
done

echo "Tag creation done"
