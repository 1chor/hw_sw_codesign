#!/bin/sh
filename="test_r_buf.txt"
rm -f $filename
echo "0000" >> "$filename"
for i in {0..510}
do
  echo "0000" >> "$filename"
done
