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
echo    ======================= PigCMS 环境控制面板 ========================
echo.
echo                 1. 启动 Apache           3. 停止 Apache
echo                 2. 启动 MySQL            4. 停止 MySQL
echo                 A1.一键启动              A2.一键停止
echo.
echo                 p1.添加虚拟主机          p2.删除虚拟主机
echo                 p3.编辑虚拟主机
echo.
echo                 r1.重新启动 Apache       r2.重新启动 MySQL
echo                 r3.重置数据库密码        r4.操作数据库(命令行)
echo.
echo    ====================== 输入 Q 将退出控制面板 ======================
echo.
set /p var=--^>请选择:
if not defined var ( echo 不能为空!&call :wait)
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
echo 输入错误!&goto wait

:start_apache
echo.
if not exist %CD%\Apache\logs\*.pid (
  net start Apache2.4
) ELSE (
  echo Apache 已经在运行...&goto wait
)
if not exist %CD%\Apache\logs\*.pid echo Apache 启动失败!
call :wait

:stop_apache
echo.
if exist %CD%\Apache\logs\*.pid (
  net stop Apache2.4
) ELSE (
echo Apache 已经停止...
)
del /F /Q /S %CD%\Apache\logs\*.pid >nul 2>nul
call :wait

:restart_apache
echo 正在重新启动 Apache...
net stop Apache2.4 >nul
net start Apache2.4 >nul
echo 重新启动完毕!
call :wait

:start_mysql
if not exist %CD%\MariaDB\data\*.pid (
  net start mysql
) ELSE (
  echo MySQL 已经在运行...&goto wait
)
if not exist %CD%\MariaDB\data\*.pid echo MySQL启动失败!请检查配置文件或者端口是否被占用...
call :wait

:stop_mysql
if exist %CD%\MariaDB\data\*.pid (
  net stop mysql
) ELSE (
  echo MySQL 已经停止...
)
if exist %CD%\MariaDB\data\*.pid echo MySQL停止失败!
call :wait

:restart_mysql
echo 正在重新启动 MySQL...
net stop mysql >nul
net start mysql >nul
echo 重新启动完毕!
call :wait

:start_memcached
net start memcached
tasklist | findstr /i memcached.exe >nul && ( echo MemCached 启动成功! ) || ( echo MemCached 启动失败! )
call :wait

:stop_memcached
net stop memcached
tasklist | findstr /i memcached.exe >nul && ( echo MemCached 停止失败! ) || ( echo MemCached 停止成功! )
call :wait

:restart_memcached
echo 重新启动 MemCached 中...
net stop memcached >nul
net start memcached >nul
echo MemCached 重新启动完毕!
call :wait

:start_all
echo 正在启动所有服务...
net start Apache2.4 >nul
net start mysql >nul
rem net start memcached
call :wait

:stop_all
echo 正在停止所有服务...
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
echo 请注意:下列虚拟主机配置文件是已经存在的!
echo 您可以使用不同的域名或地址来命名
echo.
setlocal enabledelayedexpansion
for /f %%i in ('dir /b %CD%\Apache\conf\vhosts\*.conf') do (
  set "list=%%i"
  echo !list:~0,-5!
)
endlocal
echo.
set /p servername=请输入您的站点域名:
set /p serveralias=请输入站点别名(没有请留空):
set /p webdir=请输入站点绝对路径:
set vhost_file=%CD%\Apache\conf\vhosts\%servername%.conf
if not defined servername (
    echo.站点域名不能为空!
    call :wait
)
if exist %CD%\Apache\conf\vhosts\%servername%.conf (
    echo 这个域名已存在!
    call :wait
)
if not defined webdir (
    echo.站点绝对路径不能为空!
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
echo 已经添加虚拟主机.正在重启Apache...
net stop Apache2.4 >nul
net start Apache2.4 >nul
call :wait

:remove_vhost
cls
echo.
echo 您可以移除下列虚拟主机:
echo.
setlocal enabledelayedexpansion
for /f %%i in ('dir /b %CD%\Apache\conf\vhosts\*.conf') do (
  set "list=%%i"
  echo !list:~0,-5!
)
endlocal
echo.
echo.
set /p remove_vhost_name=请输入虚拟主机名称:
if not exist %CD%\Apache\conf\vhosts\%remove_vhost_name%.conf (
  echo %remove_vhost_name% 并不存在!
) ELSE ( 
  del /F /S /Q %CD%\Apache\conf\vhosts\%remove_vhost_name%.conf >nul
)
if not exist  %CD%\Apache\conf\vhosts\%remove_vhost_name%.conf echo 已移除虚拟主机,正在重启Apache...
net stop Apache2.4 >nul
net start Apache2.4 >nul
call :wait

:edit_vhost
cls
echo 您可以编辑下列虚拟主机:
echo.
setlocal enabledelayedexpansion
for /f %%i in ('dir /b %CD%\Apache\conf\vhosts\*.conf') do (
  set "list=%%i"
  echo !list:~0,-5!
)
endlocal
echo.
echo.
set /p edit_vhost_name=请输入虚拟主机名称:
if not exist %CD%\Apache\conf\vhosts\%edit_vhost_name%.conf (
  echo %edit_vhost_name% 并不存在!
) ELSE ( 
  start "" "%windir%\System32\Notepad2.exe" %CD%\Apache\conf\vhosts\%edit_vhost_name%.conf
)
call :wait

:reset_db_password
set /p pass=请输入新密码:
echo 跳权限启动MySQL...
net stop mysql >nul
.\PigCore\fart.exe %CD%\MariaDB\my.ini #skip_grant_tables skip_grant_tables >nul
net start mysql >nul
echo 正在更新root密码...
%CD%\MariaDB\bin\mysql -uroot -e "update mysql.user set password=PASSWORD('%pass%') where User='root';" 2>nul
%CD%\MariaDB\bin\mysql -uroot -e "flush privileges;" 2>nul
.\PigCore\fart.exe %CD%\MariaDB\my.ini skip_grant_tables #skip_grant_tables >nul
echo 成功更新MySQL密码...
echo 新密码是: %pass%
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
echo 程序将在数秒后退出...
echo.
ping 127.0.0.1 -n 3 >nul
exit