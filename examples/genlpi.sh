#!/bin/sh
APPNAME=$1

if [ -z "$1" ]; then
	echo Usage: 
	echo genlpi.sh Projectname
	exit 1
fi

if [ ! -d $APPNAME ]; then
  echo Project "$APPNAME" does not exist in current directory
  exit 1
fi

rm -f $APPNAME/*.lpi
rm -f $APPNAME/*.lps

cat templates/template.lpi | sed -e "s,%%APPNAME%%,$APPNAME,g" \
                         >$APPNAME/$APPNAME.lpi
echo $APPNAME/$APPNAME.lpi created

if [ ! -f $APPNAME/$APPNAME.pp ]; then
  cat templates/template.pp | sed "s,%%APPNAME%%,$APPNAME,g" >$APPNAME/$APPNAME.pp
  echo $APPNAME/$APPNAME.pp created
fi
