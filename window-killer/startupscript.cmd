PowerShell -Command "Set-ExecutionPolicy Unrestricted" >> "%TEMP%\StartupLog.txt" 2>&1
PowerShell "%USERPROFILE%\Desktop\script.ps1" >> "%TEMP%\StartupLog.txt" 2>&1