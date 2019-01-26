#!/bin/sh
filename="test_l_buf.txt"
rm -f $filename
echo "0001" >> "$filename"
for i in {0..510}
do
  echo "0001" >> "$filename"
done
