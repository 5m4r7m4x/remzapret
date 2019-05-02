#!/bin/sh

SCRIPT=$(readlink -f $0)
EXEDIR=$(dirname $SCRIPT)
BINS=binaries
BINDIR=$EXEDIR/$BINS

check_dir()
{
 echo 0.0.0.0 | "$BINDIR/$1/ip2net" 1>/dev/null 2>/dev/null
}

# link or copy executables. uncomment either ln or cp, comment other
ccp()
{
 local F=$(basename $1)
 [ -f "$EXEDIR/$2/$F" ] && rm -f "$EXEDIR/$2/$F"
 ln -fs "../$BINS/$1" "$EXEDIR/$2" && echo linking : "../$BINS/$1" =\> "$EXEDIR/$2"
 #cp -f "$BINDIR/$1" "$EXEDIR/$2" && echo copying : "$BINDIR/$1" =\> "$EXEDIR/$2"
}

for arch in aarch64 armhf mips32r1-lsb mips32r1-msb x86_64 x86
do
 if check_dir $arch; then
  echo $arch is OK
  echo installing binaries ...
  ccp $arch/ip2net ip2net
  ccp $arch/mdig mdig
  ccp $arch/nfqws nfq
  ccp $arch/tpws tpws
  break
 else
  echo $arch is NOT OK
 fi
done

