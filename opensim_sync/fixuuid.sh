#!/bin/bash 
#
# This script regenerates the asset UUIDs for all LSL scripts in an IAR file.
# This is done so that when a script has been updated inside the IAR rather than in world...
# ...then reimported into an SL grid that had it before, or using a viewer that already has it in the cache...
# ...we can be sure that the new version will be used, not the old one.
#
# These UUIDs are generated based on the md5 hash of the contents of the script.
# This means that given two identical scripts with different UUIDs,
# ...it will have the side effect of combining them into a single script.
#
# It is intended to be used as follows on an untarred IAR, like the one in sloodle_opensim_iar:
# cd sloodle_opensim_iar/iar
# find . -name '*.lsl' -exec ../../sloodle_development_tools/opensim_sync/fixuuid.sh {} \;
#

OLDASSET=$1

if [ ! -f "$OLDASSET" ]
then
	echo "Asset '$OLDASSET' not found"
	exit 1;
fi

#./assets/432e3970-5331-b90e-b157-08e3d3fa0ef1_script.lsl
HASH=`md5sum $OLDASSET`
NEWUUID="${HASH:0:8}-${HASH:8:4}-${HASH:12:4}-${HASH:16:4}-${HASH:20:12}"

OLDSCRIPT=`echo $OLDASSET | awk -F'/' '{print $3}'`
OLDUUID=`echo $OLDSCRIPT | awk -F'_' '{print $1}'`

if [ "$NEWUUID" = "" ] 
then
	echo "Could not make NEWUUID for file '$OLDASSET'"
	exit 2
fi

if [ "$OLDUUID" = "" ] 
then
	echo "Could not make OLDUUID"
	exit 2
fi


if [ "$NEWUUID" != "$OLDUUID" ] 
then
	NEWASSET="./assets/${NEWUUID}_script.lsl"
	echo "Renaming old asset $OLDASSET to $NEWASSET"

	mv $OLDASSET $NEWASSET
	find . -name '*.xml' -exec sed -i "s/$OLDUUID/$NEWUUID/g" '{}' \;
fi
