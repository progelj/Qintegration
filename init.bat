@echo off
set title=ParenchimaCost
set exe=matlab
set folder=%~dp0
set entrada=%1
set file=parenchimaHandson('%entrada%');
start "%title%" /w /B %exe% -r \"cd %folder%; %file%\"
exit