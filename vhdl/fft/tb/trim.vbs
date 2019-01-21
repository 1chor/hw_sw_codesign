filename_r = "C:\Users\adejm\Desktop\temp.txt"
filename_w = "C:\Users\adejm\Desktop\result_2_imag.txt"

Set fso = CreateObject("Scripting.FileSystemObject")
Set f_read = fso.OpenTextFile(filename_r)
Set f_write = fso.CreateTextFile(filename_w,True)

Do Until f_read.AtEndOfStream
  line = f_read.ReadLine
  
  select case len(line)-1
  case "1"
	f_write.WriteLine("0000000" & line)
  case "2"
	f_write.WriteLine("000000" & line)
  case "3"
	f_write.WriteLine("00000" & line)
  case "4"
	f_write.WriteLine("0000" & line)
  case "5"
    f_write.WriteLine("000" & line)
  case "6"
    f_write.WriteLine("00" & line)
  case "7"
    f_write.WriteLine("0" & line)
  case "8"
	f_write.WriteLine(line)
  end select
Loop

f_read.Close
f_write.Close