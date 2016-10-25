@echo off
color 0e
rem get parent Directory
pushd "%~dp0"
cd ..
set path=%CD%
popd

%path%\MariaDB\bin\mysql -uroot -p
exit