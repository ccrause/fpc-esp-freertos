#!/bin/sh

output=sdkconfig.inc

cat sdkconfig > $output
# Remove comments
sed -i '/#/d' $output
# Remove empty lines
sed -i '/^$/d' $output
# Close all lines with }
sed -i 's/$/}/' $output
# Change = to :=
sed -i 's/=/ := /' $output
# Change 0x to $
sed -i 's/0x/$/' $output
# Change " to '
sed -i 's/"/'\''/g' $output
# Change y to true
sed -i 's/:= y}/:= true}/' $output
# Add Defines
sed -i 's/CONFIG_/  {$define CONFIG_/' $output

# Heading
sed -i "1 i \ \ {\$macro on}" $output
sed -i "2 i \ \ { Automatically generated file based on sdkconfig. DO NOT EDIT. }\n" $output

