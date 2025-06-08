@echo off
setlocal
set DIR=%~dp0
java -jar "%DIR%target\scrutinaut-app-1.0-SNAPSHOT-jar-with-dependencies.jar" %*
endlocal