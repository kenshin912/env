@echo off
@setlocal enableextensions
@cd %~dp0
REM Author:Cathryn

mode con cols=70 lines=28
title PigCMS Management Console
color 0a
set tab=    

:loop
cls
echo.
echo    ======================== PigCMS env ========================
echo.
echo               1. Start Apache           3. Stop Apache
echo               2. Start MySQL            4. Stop MySQL
echo               A1.Start All              A2.Stop All
echo.
echo               p1.Add VirtualHost        p3.Edit VirtualHost
echo               p2.Del VirtualHost
echo.
echo               r1.Restart Apache         r3.Reset MySQL Pass
echo               r2.Restart MySQL          r4.Operate DataBase
echo.
echo    ======================= Exit with Q ========================
echo.
set /p var=--^>Make Choice:
if not defined var ( echo Can not be empty!&call :wait)
if /i "%var%"=="1" call :start_apache
if /i "%var%"=="2" call :start_mysql
if /i "%var%"=="3" call :stop_apache
if /i "%var%"=="4" call :stop_mysql
if /i "%var%"=="A1" call :start_all
if /i "%var%"=="A2" call :stop_all
if /i "%var%"=="p1" call :add_vhost
if /i "%var%"=="p2" call :remove_vhost
if /i "%var%"=="p3" call :edit_vhost
if /i "%var%"=="r1" call :restart_apache
if /i "%var%"=="r2" call :restart_mysql
if /i "%var%"=="r3" call :reset_db_password
if /i "%var%"=="r4" call :operational_database
if /i "%var%"=="export" call :export
if /i "%var%"=="q" goto eof
echo Error INPUT!&goto wait

:start_apache
echo.
if not exist %CD%\Apache\logs\*.pid (
  net start Apache2.4
) ELSE (
  echo Apache is already running...&goto wait
)
if not exist %CD%\Apache\logs\*.pid echo Apache start failed!
goto wait

:stop_apache
echo.
if exist %CD%\Apache\logs\*.pid (
  net stop Apache2.4
) ELSE (
echo Apache is already stopped...
)
del /F /Q /S %CD%\Apache\logs\*.pid >nul 2>nul
goto wait

:restart_apache
echo Restarting Apache...
net stop Apache2.4 >nul
net start Apache2.4 >nul
echo Restarted!
goto wait

:start_mysql
if not exist %CD%\MariaDB\data\*.pid (
  net start mysql
) ELSE (
  echo MySQL is already running...&goto wait
)
if not exist %CD%\MariaDB\data\*.pid echo MySQL start failed!
goto wait

:stop_mysql
if exist %CD%\MariaDB\data\*.pid (
  net stop mysql
) ELSE (
  echo MySQL is already Stopped...
)
if exist %CD%\MariaDB\data\*.pid echo MySQL stop failed!
goto wait

:restart_mysql
echo Restarting MySQL...
net stop mysql >nul
net start mysql >nul
echo Restarted!
goto wait

:start_all
echo Start All Service...
net start Apache2.4 >nul
net start mysql >nul
goto wait

:stop_all
echo Stop All Service...
net stop Apache2.4 >nul
net stop mysql >nul
goto wait

:scan_vhosts
rem can not call when "for" command in a label...-_-!
rem Code finished in HeFei , Apr.15 2016

:FART
rem FART means Find And Replace Text
rem %1 is file path , %2 is the text will be replaced , %3 is replace text
.\PigCore\fart.exe %1 %2 %3
prompt

:add_vhost
cls
echo.
echo Attention:The following file is existed!
echo You can name it by domain
echo.
setlocal enabledelayedexpansion
for /f %%i in ('dir /b %CD%\Apache\conf\vhosts\*.conf') do (
  set "list=%%i"
  echo !list:~0,-5!
)
endlocal
echo.
set /p servername=Your domain:
set /p serveralias=Your Alias domain(or empty):
set /p webdir=Your WebSite absolute path:
set vhost_file=%CD%\Apache\conf\vhosts\%servername%.conf
if not defined servername (
    echo.Doamin can not be empty!
    call :wait
)
if exist %CD%\Apache\conf\vhosts\%servername%.conf (
    echo Domain already exist!
    call :wait
)
if not defined webdir (
    echo.WebSite absolute path can not be empty!
    call :wait
)
(
echo ^<VirtualHost *:80^>
echo %tab%DocumentRoot "%webdir%"
echo %tab%ServerName %servername%
echo %tab%ServerAlias %serveralias%
echo %tab%DirectoryIndex index.html index.php
echo %tab%^<Directory "%webdir%"^>
echo %tab%%tab%Options FollowSymLinks ExecCGI
echo %tab%%tab%AllowOverride All
echo %tab%%tab%Require all granted
echo %tab%^</Directory^>
echo %tab%^<LocationMatch "/(Common|Conf|Extend|images|Lang|Lib|PigCms|tpl|uploads)/(.*).(php|php5|phps|asp|aspx|jsp)$"^>
echo %tab%%tab%Require all denied
echo %tab%^</LocationMatch^>
echo ^</VirtualHost^>
)>%vhost_file%
echo.
echo VirtualHost added,restarting Apache...
net stop Apache2.4 >nul
net start Apache2.4 >nul
goto wait

:remove_vhost
cls
echo.
echo Remove the following VirtualHost:
echo.
setlocal enabledelayedexpansion
for /f %%i in ('dir /b %CD%\Apache\conf\vhosts\*.conf') do (
  set "list=%%i"
  echo !list:~0,-5!
)
endlocal
echo.
echo.
set /p remove_vhost_name=VirtualHost name:
if not exist %CD%\Apache\conf\vhosts\%remove_vhost_name%.conf (
  echo %remove_vhost_name% does not exist!
) ELSE ( 
  del /F /S /Q %CD%\Apache\conf\vhosts\%remove_vhost_name%.conf >nul
)
if not exist  %CD%\Apache\conf\vhosts\%remove_vhost_name%.conf echo VirtualHost removed , restarting Apache...
net stop Apache2.4 >nul
net start Apache2.4 >nul
goto wait

:edit_vhost
cls
echo Edit the following VirturalHost:
echo.
setlocal enabledelayedexpansion
for /f %%i in ('dir /b %CD%\Apache\conf\vhosts\*.conf') do (
  set "list=%%i"
  echo !list:~0,-5!
)
endlocal
echo.
echo.
set /p edit_vhost_name=VirtualHost name:
if not exist %CD%\Apache\conf\vhosts\%edit_vhost_name%.conf (
  echo %edit_vhost_name% does not exist!
) ELSE ( 
  start "" "%windir%\System32\Notepad2.exe" %CD%\Apache\conf\vhosts\%edit_vhost_name%.conf
)
goto wait

:reset_db_password
set /p pass=New Password:
echo Skip grant tables...
net stop mysql >nul
.\PigCore\fart.exe %CD%\MariaDB\my.ini #skip_grant_tables skip_grant_tables >nul
net start mysql >nul
echo Update root password...
%CD%\MariaDB\bin\mysql -uroot -e "update mysql.user set password=PASSWORD('%pass%') where User='root';" 2>nul
%CD%\MariaDB\bin\mysql -uroot -e "flush privileges;" 2>nul
.\PigCore\fart.exe %CD%\MariaDB\my.ini skip_grant_tables #skip_grant_tables >nul
echo update success.
echo Password: %pass%
call :restart_mysql

:operational_database
start %CD%\PigCore\mysql.cmd
goto wait

:export
start %CD%\PigCore\export.cmd
goto wait

:random
SetLocal EnableDelayedExpansion
set Str=abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ
for /l %%L in (1 1 16) do (
    set /a n = !random! %% 62
    for %%n in (!n!) do set Out=!Out!!Str:~%%n,1!
)
echo !Out!
EndLocal
pause
goto wait

:wait
ping 127.0.0.1 -n 3 >nul
goto loop

:eof
echo.
echo Program will quit in few seconds...
echo.
ping 127.0.0.1 -n 3 >nul
exit