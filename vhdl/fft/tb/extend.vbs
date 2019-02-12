filename_r = "C:\Users\adejm\Desktop\Extend\_r_buf.txt"
filename_w = "C:\Users\adejm\Desktop\Extend\r_buf.txt"

Set fso = CreateObject("Scripting.FileSystemObject")
Set f_read = fso.OpenTextFile(filename_r)
Set f_write = fso.CreateTextFile(filename_w,True)

Do Until f_read.AtEndOfStream
  line = f_read.ReadLine
  
  f_write.WriteLine("0000" & line)

Loop

f_read.Close
f_write.Close