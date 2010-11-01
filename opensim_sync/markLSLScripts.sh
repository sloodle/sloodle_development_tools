#!/bin/sh
# Commands to append a note to every LSL script under trunk with a showing where it lives in SVN.
# This is intended to help us deploy from Subversion directly into an .oar file.
# ...or commit code changed in an object back into Subversion without any unreliable copying-and-pasting.
# We may need something slightly more sophisticated later to cope with moving things around.

cd ../../trunk/sloodle
find * -name '*.lsl' -exec sh -c "echo \"// Please leave the following line intact to show where the script lives in Subversion:\n// SLOODLE LSL Script Subversion Location: {} \" >> {}" \;

