#!/bin/bash
FILES=$1/wapgw/*.csv
for f in $FILES
do
  # take action on each file. $f store current file name
  #sed -n '/Request/,${p}' "$f" > "$f"
  mv "$f" `echo $f | tr ' ' '_'`
done

for arc in $FILES
do
  # take action on each file. $f store current file name
  sed -i -n '/Request/,${p}' $arc
  # Delete all trailing blank lines at end of file (only).
  sed -i '/^\s*$/d' $arc
done
