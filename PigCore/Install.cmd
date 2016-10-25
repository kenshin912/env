@echo off
title PigCMS ENV Install
color 0a

pushd "%~dp0"
cd..
set parent=%CD%
popd

set ApacheDir=%parent%\Apache
set tmpdir=%parent%\tmp
set fcgi_path=%parent%
set "fcgi_path=%fcgi_path:\=/%"

echo 正在安装...
%~dp0fart.exe %ApacheDir%\conf\httpd.conf Apache_SRVROOT %ApacheDir% >nul
%~dp0fart.exe %parent%\PHP\php.ini session.save_path_config %tmpdir% >nul
(
echo ^<IfModule fcgid_module^>
echo Include conf/extra/httpd-fastcgi.conf
echo FcgidInitialEnv PHPRC "%fcgi_path%/PHP"
echo AddHandler fcgid-script .php
echo FcgidWrapper "%fcgi_path%/PHP/php-cgi.exe" .php
echo ^</IfModule^>
) >%ApacheDir%\conf\extra\httpd-php.conf 2>nul

echo 安装Notepad2编辑器...
if not exist %windir%\System32\Notepad2.exe (
  copy %~dp0Notepad2.exe %windir%\System32\Notepad2.exe >nul
  reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" /v "Debugger" /t REG_SZ /d "\"C:\\Windows\\System32\\Notepad2.exe\" /z" /f
) else (
  echo Notepad2.exe has already installed!
)

echo 安装vc9...
wmic product get name | findstr /C:"Microsoft Visual C++ 2008 Redistributable" >nul
if errorlevel 1 (
  %~dp0vcredist_x86.exe /q
) else (
  echo Microsoft Visual C++ 2008 has already installed!
)

echo 安装7-Zip...
if not exist %HOMEDRIVE%\PROGRA~1\7-Zip\7z.exe (
    if /i "%processor_architecture%"=="x86" (
        msiexec /i 7zx86.msi /qn /norestart
    ) else (
        msiexec /i 7zx64.msi /qn /norestart
    )
) else (
    echo 7-Zip has already installed!
)
echo 注册系统服务...
%parent%\Apache\bin\httpd.exe -k install 2>nul
%parent%\MariaDB\bin\mysqld.exe --install MySQL --defaults-file=%parent%\MariaDB\my.ini 2>nul
mshta vbscript:msgbox("运行环境安装完成!",64,"PigCMS")(window.close)
exit
