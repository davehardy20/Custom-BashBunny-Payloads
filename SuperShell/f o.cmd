@echo off
start (path to program here)
cscript %~dp0\i.vbs %~dp0\z.cmd
@exit

REM The above may no longer be needed


start "" /b "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
start "" /b "%USERPROFILE%\Desktop\test.cmd"
