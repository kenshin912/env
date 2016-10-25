@echo off
@setlocal enableextensions
@cd %~dp0

mode con cols=80 lines=30
title PigCMS Management Console
color 0a
set tab=    

:loop
cls
echo.
echo    ======================= PigCMS ����������� ========================
echo.
echo                 1. ���� Apache           3. ֹͣ Apache
echo                 2. ���� MySQL            4. ֹͣ MySQL
echo                 A1.һ������              A2.һ��ֹͣ
echo.
echo                 p1.�����������          p2.ɾ����������
echo                 p3.�༭��������
echo.
echo                 r1.�������� Apache       r2.�������� MySQL
echo                 r3.�������ݿ�����        r4.�������ݿ�(������)
echo.
echo    ====================== ���� Q ���˳�������� ======================
echo.
set /p var=--^>��ѡ��:
if not defined var ( echo ����Ϊ��!&call :wait)
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
if /i "%var%"=="q" goto eof
echo �������!&goto wait

:start_apache
echo.
if not exist %CD%\Apache\logs\*.pid (
  net start Apache2.4
) ELSE (
  echo Apache �Ѿ�������...&goto wait
)
if not exist %CD%\Apache\logs\*.pid echo Apache ����ʧ��!
call :wait

:stop_apache
echo.
if exist %CD%\Apache\logs\*.pid (
  net stop Apache2.4
) ELSE (
echo Apache �Ѿ�ֹͣ...
)
del /F /Q /S %CD%\Apache\logs\*.pid >nul 2>nul
call :wait

:restart_apache
echo ������������ Apache...
net stop Apache2.4 >nul
net start Apache2.4 >nul
echo �����������!
call :wait

:start_mysql
if not exist %CD%\MariaDB\data\*.pid (
  net start mysql
) ELSE (
  echo MySQL �Ѿ�������...&goto wait
)
if not exist %CD%\MariaDB\data\*.pid echo MySQL����ʧ��!���������ļ����߶˿��Ƿ�ռ��...
call :wait

:stop_mysql
if exist %CD%\MariaDB\data\*.pid (
  net stop mysql
) ELSE (
  echo MySQL �Ѿ�ֹͣ...
)
if exist %CD%\MariaDB\data\*.pid echo MySQLֹͣʧ��!
call :wait

:restart_mysql
echo ������������ MySQL...
net stop mysql >nul
net start mysql >nul
echo �����������!
call :wait

:start_memcached
net start memcached
tasklist | findstr /i memcached.exe >nul && ( echo MemCached �����ɹ�! ) || ( echo MemCached ����ʧ��! )
call :wait

:stop_memcached
net stop memcached
tasklist | findstr /i memcached.exe >nul && ( echo MemCached ֹͣʧ��! ) || ( echo MemCached ֹͣ�ɹ�! )
call :wait

:restart_memcached
echo �������� MemCached ��...
net stop memcached >nul
net start memcached >nul
echo MemCached �����������!
call :wait

:start_all
echo �����������з���...
net start Apache2.4 >nul
net start mysql >nul
rem net start memcached
call :wait

:stop_all
echo ����ֹͣ���з���...
net stop Apache2.4 >nul
net stop mysql >nul
rem net stop memcached
call :wait

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
echo ��ע��:�����������������ļ����Ѿ����ڵ�!
echo ������ʹ�ò�ͬ���������ַ������
echo.
setlocal enabledelayedexpansion
for /f %%i in ('dir /b %CD%\Apache\conf\vhosts\*.conf') do (
  set "list=%%i"
  echo !list:~0,-5!
)
endlocal
echo.
set /p servername=����������վ������:
set /p serveralias=������վ�����(û��������):
set /p webdir=������վ�����·��:
set vhost_file=%CD%\Apache\conf\vhosts\%servername%.conf
if not defined servername (
    echo.վ����������Ϊ��!
    call :wait
)
if exist %CD%\Apache\conf\vhosts\%servername%.conf (
    echo ��������Ѵ���!
    call :wait
)
if not defined webdir (
    echo.վ�����·������Ϊ��!
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
echo �Ѿ������������.��������Apache...
net stop Apache2.4 >nul
net start Apache2.4 >nul
call :wait

:remove_vhost
cls
echo.
echo �������Ƴ�������������:
echo.
setlocal enabledelayedexpansion
for /f %%i in ('dir /b %CD%\Apache\conf\vhosts\*.conf') do (
  set "list=%%i"
  echo !list:~0,-5!
)
endlocal
echo.
echo.
set /p remove_vhost_name=������������������:
if not exist %CD%\Apache\conf\vhosts\%remove_vhost_name%.conf (
  echo %remove_vhost_name% ��������!
) ELSE ( 
  del /F /S /Q %CD%\Apache\conf\vhosts\%remove_vhost_name%.conf >nul
)
if not exist  %CD%\Apache\conf\vhosts\%remove_vhost_name%.conf echo ���Ƴ���������,��������Apache...
net stop Apache2.4 >nul
net start Apache2.4 >nul
call :wait

:edit_vhost
cls
echo �����Ա༭������������:
echo.
setlocal enabledelayedexpansion
for /f %%i in ('dir /b %CD%\Apache\conf\vhosts\*.conf') do (
  set "list=%%i"
  echo !list:~0,-5!
)
endlocal
echo.
echo.
set /p edit_vhost_name=������������������:
if not exist %CD%\Apache\conf\vhosts\%edit_vhost_name%.conf (
  echo %edit_vhost_name% ��������!
) ELSE ( 
  start "" "%windir%\System32\Notepad2.exe" %CD%\Apache\conf\vhosts\%edit_vhost_name%.conf
)
call :wait

:reset_db_password
set /p pass=������������:
echo ��Ȩ������MySQL...
net stop mysql >nul
.\PigCore\fart.exe %CD%\MariaDB\my.ini #skip_grant_tables skip_grant_tables >nul
net start mysql >nul
echo ���ڸ���root����...
%CD%\MariaDB\bin\mysql -uroot -e "update mysql.user set password=PASSWORD('%pass%') where User='root';" 2>nul
%CD%\MariaDB\bin\mysql -uroot -e "flush privileges;" 2>nul
.\PigCore\fart.exe %CD%\MariaDB\my.ini skip_grant_tables #skip_grant_tables >nul
echo �ɹ�����MySQL����...
echo ��������: %pass%
call :restart_mysql

:operational_database
start %CD%\PigCore\mysql.cmd
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
call :wait

:wait
ping 127.0.0.1 -n 3 >nul
goto loop

:eof
echo.
echo ������������˳�...
echo.
ping 127.0.0.1 -n 3 >nul
exit