; USERCONFIG: MODIFY THESE SETTINGS ===
static global $service_name = "valhiemDedicatedServerAutoStart"
static global $server_name = "Valheim Dedicated Server"
static global $server_dir = "C:\Program Files(x86) \Steam\steamapps\common\Valheim dedicated server"
static global $server_exe = "valheim_server.exe"
static global $app_id = 896660
static global $steamcmd_dir = "C:\SteamCMD"
static global $steamcmd_exe = "steamcmd.exe"
static global $steam_user = ""
static global $steam_pw = ""
static global $working_dir = "C:\Users\Admin\Desktop\Valhiem Service Manager"
; USERCONFIG END ========================

;START
if $steam_user == "" Then $steam_user == "anonymous"
ConsoleWrite("- Updating " & $server_name & " ...")

;STOP SERVER SERVICE
ConsoleWrite("- Stop Service: " & $service_name & ".")
if is_exe_running() Then stop_service()

;VERIFY SERVER HAS STOPPED
if is_exe_running() Then error1()

;UPDATE SERVER
ConsoleWrite("- Updating " & $server_name )
local $commandName = ""& $steamcmd_dir & "\" & $steamcmd_exe & " +force_install_dir " & $server_dir & " +login " & $steam_user &" "& $steam_pw & " +app_update " & $app_id & " -beta public validate +quit"
run_cmd_wait($commandName)

;END
ConsoleWrite(" - Starting Service: %service_exe% ")
start_service()
if NOT is_exe_running() Then error3()
ConsoleWrite("- UPDATE COMPLETED")
Exit

; ERRORS ==============================
Func error1()
	ConsoleWrite("- ERROR1-FATAL: " & $server_name & " is still running!" )
	ConsoleWrite("- Check the Windows Service and/or close " & $server_exe manually & " and try again." )
	Exit(1)
EndFunc   ;==>error1

;Func error2()
;	ConsoleWrite ( "- ERROR2-WARN: An unknown "& $steamcmd_exe &" error occured."
;	ConsoleWrite ( "- "& $server_name &" may not have updated properly, check the logs."
;	ConsoleWrite ( "- We did not automatically restart "& $server_exe &" ."
;	Exit(2)
;EndFunc

Func error3()
	ConsoleWrite("- ERROR3: " & $server_exe & " did not restart!")
EndFunc   ;==>error3

; FUNCTIONS ===========================
Func run_cmd_wait(ByRef $commandName)
	RunWait('"' & @ComSpec & '" /c ' & $commandName, @SystemDir)
EndFunc   ;==>run_cmd_wait

Func is_exe_running()
;Returns PID if EXE is running. Returns 0 if not running.
	return (ProcessExists($server_exe))
EndFunc

Func stop_service()
	;Send singal to stop Service
	local $commandName = "net stop "& $service_name & ""
	run_cmd_wait($commandName)
	Sleep(20000)
EndFunc   ;==>stop_service

Func start_service()
	;Send singal to start Service
	local $commandName = "net start "& $service_name & ""
	run_cmd_wait($commandName)
	Sleep(20000)
EndFunc   ;==>start_service
