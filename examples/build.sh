#!/bin/sh
curdir=$(pwd)
ls $1/*.lpi | while read lpi ; do
  echo "Building $lpi"
  cd $curdir/$(dirname $lpi)
  lazbuild --build-all $(basename $lpi) | grep -e "lines compiled" -e Fatal -e "Illegal parameter"
  echo ""
done
echo ""
