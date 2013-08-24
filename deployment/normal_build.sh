#!/bin/sh
TAG=$1
./tag_release.sh $TAG tmp release-v2.1 1
./make_tarballs.sh $TAG tmp /var/www/download/webroot/sloodle/


