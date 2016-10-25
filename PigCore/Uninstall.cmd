@echo off
title PigCMS ENV Uninstall
color 0a

pushd "%~dp0"
cd..
set parent=%CD%
popd

set ApacheDir=%parent%\Apache
set tmpdir=%parent%\tmp

echo 正在卸载...
net stop Apache2.4 >nul
net stop MySQL >nul
%~dp0fart.exe %ApacheDir%\conf\httpd.conf %ApacheDir% Apache_SRVROOT >nul
%~dp0fart.exe %parent%\PHP\php.ini %tmpdir% session.save_path_config >nul
del /F /S /Q %ApacheDir%\conf\extra\httpd-php.conf >nul
rem reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" /f
%parent%\Apache\bin\httpd.exe -k uninstall 2>nul
%parent%\MariaDB\bin\mysqld.exe --remove MySQL 2>nul
mshta vbscript:msgbox("运行环境卸载完成!",64,"PigCMS")(window.close)
exit