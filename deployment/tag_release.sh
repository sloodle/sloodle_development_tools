#!/bin/sh
TAG=$1
WORKINGDIR=$2
BRANCH=$3
AVATARCLASSROOMTOO=$4

if [ "$1" = "" ]; then
   echo "Usage: ../sloodle_development_tools/deployment/tag_release.sh <tag> <working_dir> [<branch>] [<includeavatarclassroom>]"
   exit
fi

if [ "$2" = "" ]; then
   echo "Usage: ../sloodle_development_tools/deployment/tag_release.sh <tag> <working_dir> [<branch>] [<includeavatarclassroom>]"
   exit
fi

echo $TAG;

mkdir $WORKINGDIR
cd $WORKINGDIR

REPOS="moodle-mod_sloodle moodle-assignment_sloodleobject moodle-block_sloodle_menu moodle-block_sloodle_backpack sloodle_opensim_iar"
for REPO in $REPOS
do
	FULLREPO="git@github.com:sloodle/${REPO}.git"
	git clone $FULLREPO 
	cd $REPO
	git checkout $BRANCH
	git pull
	git tag $TAG
	git push --tags
	cd ..
	rm -rf $REPO
done

if [ "$AVATARCLASSROOMTOO" != "" ]; then
    git clone "git@github.com:edmundedgar/avatarclassroom_opensim_iar.git"
	cd avatarclassroom_opensim_iar
	git pull
	git tag $TAG
	git push --tags
	cd ..
fi

echo "Tag creation done, cleaning up"
cd ..
rm -rf $WORKINGDIR
