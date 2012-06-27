#!/bin/bash 

BEFORE=$1
AFTER=$2

pushd ../../moodle-mod_sloodle
if [ ! -f "$AFTER" ]; then
	if [ ! -d "$AFTER" ]; then
		mkdir -p $AFTER
		rmdir $AFTER
		git mv $BEFORE $AFTER
	fi
	git mv $BEFORE $AFTER
fi

find . -type f -name '*.lslp' -print0 | xargs -0 perl -i -pe "s#$BEFORE#$AFTER#g" *.lsl
popd

pushd ../../avatarclassroom_opensim_iar/iar/assets
perl -i -pe "s#$BEFORE#$AFTER#g" *.lsl
popd

pushd ../../sloodle_opensim_iar/iar/assets
perl -i -pe "s#$BEFORE#$AFTER#g" *.lsl
popd
