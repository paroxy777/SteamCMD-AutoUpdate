@echo off
:: USERCONFIG: MODIFY THESE SETTINGS ===
set service_name=valhiemDedicatedServerAutoStart
set server_name=Valheim Dedicated Server
set server_dir=C:\Program Files (x86)\Steam\steamapps\common\Valheim dedicated server
set server_exe=valheim_server.exe
set app_id=896660
set steamcmd_dir=C:\SteamCMD
set steamcmd_exe=steamcmd.exe
set steam_user=
set working_dir="C:\Users\Admin\Desktop\Valhiem Service Manager"
:: /USERCONFIG ========================

:start
if [%steam_user%]==[] set steam_user=anonymous
cd %working_dir%
cls
title Update %server_name%
echo - Updating %server_name%...

:stop_valheim_server_service
echo - Stop Service: %service_name%
::Check if %service_exe% is running and stop it
call :is_service_running && goto :server_exe_check
call :stop_service

:server_exe_check
::Finial check if %server_exe% is running
call :is_exe_running || goto :update_server
goto :error1

:update_server
echo - Updating %server_name%
"%steamcmd_dir%\%steamcmd_exe%" +force_install_dir "%server_dir%" +login %steam_user% %steam_pw% +app_update %app_id% -beta public validate +quit
:: (SteamCMD exit codes are undocumented and gives unpredictable ERRORLEVELS)
rem if %ERRORLEVEL% NEQ 1 goto :error2

:end
echo - Starting Service: %service_exe%
call :start_service
call :is_exe_running || goto :error3
echo UPDATE COMPLETED
goto :eof

:: === ERRORS ========================
goto :eof
:error1
echo - ERROR1: %steamcmd_exe% is still running! 
echo - Check the Windows Service and/or close %server_exe% manually and try again.
echo - SERVICE STATUS: -
sc.exe queryex "%service_name%"
echo -
echo - EXE STATUS: -
tasklist /nh /fi "Imagename eq %server_exe%"
echo -
choice /M "- Force Kill %server_exe% now and retry update?"
if %ERRORLEVEL% EQU 1 call :force_kill_exe
call :is_exe_running || goto :update_server
echo - FATAL ERROR - CANT STOP %server_exe% !!!!
exit /b 1

:error2
echo - ERROR2: An unknown %steamcmd_exe% error occured! 
echo - %server_name% may not have updated properly, check the logs.
exit /b 2

:error3
echo - ERROR3: %server_exe% did not restart!
exit /b 3

:: === SUBROUTINES ===================
goto :eof
:force_kill_exe
:: disable service auto-start parameter
nssm set %service_name% Start SERVICE_DISABLED
call :stop_service
call :taskkill
:: enable service auto-start parameter
nssm set %service_name% Start SERVICE_AUTO_START
goto :eof

:taskkill
taskkill /f /im %server_exe%
call :timeout 20
goto :eof

:is_service_running
:: ERRORLEVELS: 0=Running, 1=NOT running (or other status)
sc.exe queryex "%service_name%"|find "STATE"|find /v "RUNNING" >Nul
if %ERRORLEVEL% NEQ 0 exit /b 1
exit /b 0
goto :eof

:is_exe_running
:: ERRORLEVELS: 0=Running, 1=NOT running
tasklist /nh /fi "Imagename eq %server_exe%" | find "%server_exe%" > NUL
if %ERRORLEVEL% NEQ 0 exit /b 1
exit /b 0
goto :eof

:stop_service
nssm stop %service_name%
CALL :timeout 20
goto :eof

:start_service
nssm start %service_name%
CALL :timeout 20
goto :eof

:timeout
:: use ping to delay for the number of seconds passed as an argument
set delay=%1
echo - Waiting for %delay% seconds ...
ping -n %1 127.0.0.1 > nul
ping -n 2 127.0.0.1 > nul
goto :eof

:: === EOF ===========================
:eof
