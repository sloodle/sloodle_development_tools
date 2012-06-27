#!/bin/sh 
#
# Edmund Edgar, 2010-11-01 as part of the Sloodle Project. 
# Licensed under the same license as Sloodle.
# Script to copy over a single file in an opensim archive with the matching contents from Git.
# For legacy reasons, this still says "Subversion".
# Assumes that both the LSL script in the iar fila and its counterpart in SVN contain a line like the following:
# // SLOODLE LSL Script Git Location: mod/awards-1.0/lsl/xytext_prims/xytext.lsl
# It is intended that this script will be passed the results of a "find" command, allowing us to sync a whole .iar file in one go.
# NB There may be some mistakes in the Subversion location lines in the iar file - these should turn up the first time we sync.
#
# Example of intended use:
# cd working/sloodle_opensim_iar
# git pull
# find iar/ -name '*.lsl' -exec ../sloodle_development_tools/opensim_sync/syncSVNScriptsToOar.sh {} \;
# git diff iar | more
# # Scan through the changes to make sure they make sense
# git add -a
# git commit -a
# git push

# The name of your sloodle module checkout
SLOODLE_ROOT=../moodle-mod_sloodle

if [ $# -ne 1 ]
then
    echo "Usage: $0 <filename.lsl>"
    exit 1
fi

FILE=$1

if test ! -f "$FILE"
then
    echo "Script $FILE not found in iar file"
    exit 2
fi

SVN_SCRIPT="`grep "SLOODLE LSL Script Subversion Location: " "$FILE" | awk -F': ' '{print $2}' | sed 's/\n//g' | sed 's/\s$//g'`"

if test -z "$SVN_SCRIPT"
then
    echo "No SVN location specified in file $FILE"
    exit 5
fi

SVN_SCRIPT="${SLOODLE_ROOT}/${SVN_SCRIPT}"
 echo $SVN_SCRIPT



if test ! -f "$SVN_SCRIPT"
then
    echo "Script $SVN_SCRIPT for file $FILE not found in sloodle repo"
    exit 4
fi

if [ `diff --brief -x --ignore-eol-style $SVN_SCRIPT $FILE | wc -l` -gt 0 ]
then
    cp $SVN_SCRIPT $FILE
fi
