@echo off
REM AUTHOR:Kenshin912
color 8F
title PigCMS Auto Backup Script

REM VARIABLE DEFINED
set webdir=%~dp0WebSite
set bakdir=%~dp0Backup
for /f "tokens=2 delims==" %%a in ('wmic os get LocalDateTime /value') do (set t=%%a)
set today=%t:~0,8%

if not exist %bakdir% mkdir %bakdir%
if not exist %bakdir% goto checkdriver
if not exist %HOMEDRIVE%\PROGRA~1\7-Zip\7z.exe goto 7z

for /f "delims=>' tokens=4" %%i in ('type %webdir%\Conf\db.php ^| findstr "DB_NAME"') do (set dbname=%%i)
for /f "delims=>' tokens=4" %%j in ('type %webdir%\Conf\db.php ^| findstr "DB_USER"') do (set dbuser=%%j)
for /f "delims=>' tokens=4" %%k in ('type %webdir%\Conf\db.php ^| findstr "DB_PWD"') do (set dbpass=%%k)

REM REMOVE CACHE DIRECTORY&FILES
REM TO PREVENT THE FILENAME CONTAINS SPACE , USE QUOTATION MARKS FOR VARIABLE %%l
for /d %%l in (%webdir%\Conf\logs\*) do (rd /S /Q "%%l")

REM COMPRESS WEB FILES & EXPORT SQL FILE & DELETE EXPRIED FILES
%HOMEDRIVE%\PROGRA~1\7-Zip\7z.exe a -mx0 %bakdir%\CMS-%today%.zip %webdir%\*
%~dp0env\MariaDB\bin\mysqldump.exe -u%dbuser% -p%dbpass% %dbname% >%bakdir%\CMS-%today%.sql
forfiles /p %bakdir% /d -5 /c "cmd /c del /Q @file" >nul

REM CHANGE CODE PAGE to 437( UNITED STATES ) IS REQUIRED
REM WHICH HAVE TO USE TASK SCHEDULER IN CHINESE LANGUAGE OPERATING SYSTEM
chcp 437
schtasks /query /tn AutoBackup
if errorlevel 1 (
  schtasks /Create /tn "AutoBackup" /tr %0 /sc daily /st 03:00
)else (
  echo Task Scheduler already exist!
)
echo Auto BackUp finished! Program will quit in few seconds...
attrib +s +h %0
ping 127.0.0.1 -n 3 >nul
exit

:checkdriver
mshta vbscript:msgbox("Unable to create folder,Please check your Disk Drive",16,"Disk Error")(window.close)
exit

:7z
mshta vbscript:msgbox("There is no 7ZIP in your Computer!",16,"7ZIP Missing")(window.close)
exit
