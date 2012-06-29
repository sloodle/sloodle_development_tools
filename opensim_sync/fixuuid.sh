#!/bin/bash 

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
