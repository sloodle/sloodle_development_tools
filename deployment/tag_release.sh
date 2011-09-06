#!/bin/sh

TAG=$1

if [ "$1" = "" ]; then
   echo "Usage: sloodle_development_tools/deployment/tag_release.sh <tag>"
   exit
fi

echo $TAG;

if [ ! -d sloodle_development_tools ]; then
   echo "The tag_release script must be run from inside the sloodle_all_submodules directory."
   exit
fi

echo "Updating all sub-modules to origin/master"
git submodule foreach git pull origin master

echo "Tagging all sub-modules with tag $TAG"
git submodule foreach git tag $TAG
git tag $TAG

echo "Pushing tags"
git submodule foreach git push --tags
git push --tags

echo "Tag creation done"

git commit -a -m "Updated and tagged submodules"
git push


