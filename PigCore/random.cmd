@echo off
SetLocal EnableDelayedExpansion
set Str=abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ
for /l %%L in (1 1 16) do (
    set /a n = !random! %% 62
    for %%n in (!n!) do set Out=!Out!!Str:~%%n,1!
)
echo !Out!
pause