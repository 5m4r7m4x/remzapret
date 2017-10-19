#!/bin/sh
# get rublacklist and resolve it

SCRIPT=$(readlink -f $0)
EXEDIR=$(dirname $SCRIPT)

. "$EXEDIR/def.sh"

ZREESTR=$TMPDIR/zapret.txt
ZDIG=$TMPDIR/zapret-dig.txt
ZIPLISTTMP=$TMPDIR/zapret-ip.txt
ZURL=https://reestr.rublacklist.net/api/current

getuser

curl -k --fail --max-time 300 --max-filesize 41943040 "$ZURL" >$ZREESTR && {
 dlsize=$(wc -c "$ZREESTR" | cut -f 1 -d ' ')
 if test $dlsize -lt 204800; then
  echo list file is too small. can be bad.
  exit 2
 fi
 sed -i 's/\\n/\r\n/g' $ZREESTR
 sed -nre 's/^[^;]*;([^;|\\]{4,250})\;.*/\1/p' $ZREESTR | sort | uniq >$ZDIG
 rm -f $ZREESTR
 echo digging started ...
 dig A +short +time=8 +tries=2 -f $ZDIG | grep -E '^[^;].*[^\.]$' | grep -vE '^192\.168\.[0-9]+\.[0-9]+$' | grep -vE '^127\.[0-9]+\.[0-9]+\.[0-9]+$' | grep -vE '^10\.[0-9]+\.[0-9]+\.[0-9]+$' >$ZIPLISTTMP || {
  rm -f $ZDIG
  exit 1
 }
 rm -f $ZDIG $ZIPLIST
 sort $ZIPLISTTMP | uniq >$ZIPLIST
 rm -f $ZIPLISTTMP
 "$EXEDIR/create_ipset.sh"
}
