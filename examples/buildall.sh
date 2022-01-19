#!/bin/sh
curdir=$(pwd)
ls -1 */*lpi | grep -v templates/ | while read lpi ; do
  printf "Building %-60s" $lpi
  cd $curdir/$(dirname $lpi)
  lazbuild --build-all $(basename $lpi) >../compile
  if [ "$?" != "0" ]; then
    echo "[FAILED]"
    rm -f ../compile 2>/dev/null
  else
    printf "[OK]    "
    cat ../compile  | grep "lines compiled" | sed "s~^.*sec,~~g"
    rm -f ../compile 2>/dev/null
  fi
done
echo ""
