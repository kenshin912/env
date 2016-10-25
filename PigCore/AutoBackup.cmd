@echo off
color 0e
title PigCMS Auto Backup Script
set webdir=%~dp0WebSite
set bakdir=%~dp0Backup
for /f "tokens=2 delims==" %%a in ('wmic os get LocalDateTime /value') do (
  set t=%%a
)
set today=%t:~0,8%
if not exist %bakdir% mkdir %bakdir%
if not exist %bakdir% goto checkdriver
if not exist %HOMEDRIVE%\PROGRA~1\7-Zip\7z.exe goto rar
for /f "skip=9 delims=>' tokens=4" %%i in (%webdir%\Conf\db.php) do (set dbname=%%i && goto :dbuser)
:dbuser
for /f "skip=10 delims=>' tokens=4" %%j in (%webdir%\Conf\db.php) do (set dbuser=%%j && goto :dbpass)
:dbpass
for /f "skip=11 delims=>' tokens=4" %%k in (%webdir%\Conf\db.php) do (set dbpass=%%k && goto :goon)
:goon
rd /S /Q %webdir%\Conf\logs\Cache
rd /S /Q %webdir%\Conf\logs\Data
rd /S /Q %webdir%\Conf\logs\Logs
rd /S /Q %webdir%\Conf\logs\Temp
%HOMEDRIVE%\PROGRA~1\7-Zip\7z.exe a -mx0 %bakdir%\%today%.zip %webdir%\*
%~dp0env\MariaDB\bin\mysqldump.exe -u%dbuser% -p%dbpass% %dbname% >%bakdir%\%today%.sql
forfiles /p %bakdir% /d -5 /c "cmd /c del /Q @file" >nul
chcp 437
schtasks /query /tn PigCMSAutoBackUP
if errorlevel 1 (
  schtasks /Create /tn "PigCMSAutoBackUP" /tr %0 /sc daily /st 03:00
)else (
  echo Task schedule already exist!
)
echo Auto BackUp Finished! Program will quit in few seconds...
attrib +s +h %0
ping 127.0.0.1 -n 3 >nul
exit

:checkdriver
mshta vbscript:msgbox("Unable to create Folder,Please check your Disk Drive",16,"Disk Error")(window.close)
exit

:rar
mshta vbscript:msgbox("There is no 7ZIP in your Computer!",16,"7ZIP Missing")(window.close)
exit