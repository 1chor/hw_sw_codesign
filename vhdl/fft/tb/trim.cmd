@echo off

for /f "eol=  tokens=2 delims= " %%a in (test.txt) do (
	echo %%a >> temp.txt
)