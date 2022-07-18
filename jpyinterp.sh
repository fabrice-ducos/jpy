#!/bin/bash

function get_property
{
    # extracts a property from a java property file
    # spaces are allowed around the assignment sign
    # leading and trailing spaces are trimmed in the property value (with sed)
    local propertyFile=$1
    local propertyName=$2
    grep "^$propertyName *=" "$propertyFile" | cut -d'=' -f2 | sed 's/^ *//;s/ *$//'
}

TOP_LEVEL_DIR=$PWD
propertyFile=`find $TOP_LEVEL_DIR -name jpyconfig.properties`

pyLib=`get_property $propertyFile jpy.pythonLib`

# This is a bit hacky: one assumes that only one copy of jpyLib and jdlLib
# is available under $TOP_LEVEL_DIR. If it is not the case, one may
# end up loading the wrong copy.
# It would be a bit safer to retrieve jpyLib and jdlLib from $propertyFile
# (like for pyLib). Unfortunately, the automatically generated property file
# contains paths to build/bdist.<platform>/wheel/ that doesn't exist (it is removed
# automatically by python setup.py, at least on MacOS).
# .so files can be found under build/lib.<platform>-<pyversion> not
# referenced in $propertyFile
jpyLib=`find $TOP_LEVEL_DIR/build -name jpy.*.so -print | head -n 1`
jdlLib=`find $TOP_LEVEL_DIR/build -name jdl.*.so -print | head -n 1`

jpyJar=`find target/ -name jpy-*.jar -print | head -n 1`

[ -f "$pyLib" ] || { echo "$0: failed to find pyLib: $pyLib" 1>&2 ; exit 1 ; }
[ -f "$jpyLib" ] || { echo "$0: failed to find jpyLib: $jpyLib" 1>&2 ; exit 1 ; }
[ -f "$jdlLib" ] || { echo "$0: failed to find jdlLib: $jdlLib" 1>&2 ; exit 1 ; }
[ -f "$jpyJar" ] || { echo "$0: failed to find jpyJar: $jpyJar" 1>&2 ; exit 1 ; }

jrunscript -Djpy.pyLib=$pyLib -Djpy.jpyLib=$jpyLib -Djpy.jdlLib=$jdlLib -cp $jpyJar -l python "$@"
