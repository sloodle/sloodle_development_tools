#!/bin/sh
# Add markins at the top of the file to displace comments that may be there.
# This stops OpenSim from mistaking them for script engine information.

cd ../../moodle-mod_sloodle
#find * -name '*.lsl' -exec sh -c "echo \"// Please leave the following line intact to show where the script lives in Git:\n// SLOODLE LSL Script Git Location: {} \" >> {}" \;
find * -name '*.lsl' -exec sh -c "if ! grep -q \"The line above should\" {}; then mv {} {}.tmp; echo \"//\n// The line above should be left blank to avoid script errors in OpenSim.\n\" >> {}; cat {}.tmp >> {}; rm {}.tmp; fi" \;

