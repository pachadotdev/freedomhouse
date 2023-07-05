#!/bin/bash

# for each file in inst/specs, use sed to replace non-ascii characters
# i.e., replace á, é, í, etc with \u00e1, \u00e9, \u00ed, etc

for file in inst/specs/*.yml
do
    sed -i 's/á/\\u00e1/g' $file
    sed -i 's/é/\\u00e9/g' $file
    sed -i 's/í/\\u00ed/g' $file
    sed -i 's/ó/\\u00f3/g' $file
    sed -i 's/ú/\\u00fa/g' $file
    sed -i 's/ñ/\\u00f1/g' $file
    sed -i 's/Á/\\u00c1/g' $file
    sed -i 's/É/\\u00c9/g' $file
    sed -i 's/Í/\\u00cd/g' $file
    sed -i 's/Ó/\\u00d3/g' $file
    sed -i 's/Ú/\\u00da/g' $file
    sed -i 's/Ñ/\\u00d1/g' $file
    sed -i 's/¿/\\u00bf/g' $file
done
