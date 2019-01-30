#!/bin/sh
filename="test_ref_real.txt"
rm -f $filename
echo "0200" >> "$filename"
for i in {0..254}
do
  echo "0000" >> "$filename"
done
