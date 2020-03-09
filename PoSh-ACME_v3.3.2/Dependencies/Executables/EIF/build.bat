rmdir /s/q build
rmdir /s/q dist
c:\python27\scripts\pyinstaller.exe eif.py --onefile
move dist\eif.exe eif64.exe
rmdir /s/q build
rmdir /s/q dist
c:\python27x32\scripts\pyinstaller.exe eif.py --onefile
move dist\eif.exe eif32.exe