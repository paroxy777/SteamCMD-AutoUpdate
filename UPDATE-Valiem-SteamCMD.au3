;=LOAD USER CONFIG
local $sIniValue = ""
static global $g_sIniFilePath = set_ini_path()
; Set gloabl configuration variables
static global $working_dir = IniRead($g_sIniFilePath, "SERVER", "working_dir", "")
static global $service_id = IniRead($g_sIniFilePath, "SERVER", "service_id", "")
static global $server_name = set_server_name()
; == server_dir: Split filename from full path specified in INI file
$sIniValue = IniRead($g_sIniFilePath, "SERVER", "server_dir", "")
if NOT FileExists($sIniValue) Then error_end("- ERROR9-FATAL: server_dir not found." &@CRLF &"-> server_dir = " &$sIniValue &@CRLF)
static global $server_dir = str_get_path($sIniValue)
static global $server_exe = str_get_filename($sIniValue)
; ==
static global $app_id = IniRead($g_sIniFilePath, "SERVER", "app_id", "")
; == steam_cmd: Split filename from full path specified in INI file
$sIniValue = IniRead($g_sIniFilePath, "SERVER", "steamcmd_dir", "")                   
if NOT FileExists($sIniValue) Then error_end("- ERROR9-FATAL: steamcmd_dir not found." &@CRLF &"-> steamcmd_dir = " &$sIniValue &@CRLF)
static global $steamcmd_dir = str_get_path($sIniValue)
static global $steamcmd_exe = str_get_filename($sIniValue)
; ==
static global $steam_user = IniRead($g_sIniFilePath, "SERVER", "steam_user", "anonymous")
static global $steam_pw = set_steam_pw()
;=

;=MAIN
; Write console header
ConsoleWrite("==== Steam_CMD AUTO UPDATER =====================" &@CRLF)
ConsoleWrite("  Updating -" &$server_name &"- via SteamCMD ... " &@CRLF)
ConsoleWrite("=================================================" &@CRLF)

; Verify user specifed data
verify_user_config(0)

; 1. STOP SERVER SERVICE
ConsoleWrite("- 1. Stopping Service: " &$service_id &"." &@CRLF)
if is_exe_running() Then stop_service()
; VERIFY SERVER HAS STOPPED
if is_exe_running() Then error1()

; 2. UPDATE SERVER
ConsoleWrite("- 2. Updating " &$server_name &@CRLF)
local $sCommandName = "" &$steamcmd_dir &"\" &$steamcmd_exe &" +force_install_dir "&$server_dir &"+login " &$steam_user &" " &$steam_pw &" +app_update " &$app_id &" -beta public validate +quit"
run_cmd_wait($sCommandName)

; 3. RESTART SERVICE
ConsoleWrite("- 3. Starting Service: "&$server_exe &"." &@CRLF)
start_service()
if NOT is_exe_running() Then error3()

; Write console footer and Exit
ConsoleWrite("==== UPDATE COMPLETED ===========================" & @CRLF)
Exit
;==


; === MAIN FUNCTIONS ===========================
Func run_cmd_wait(ByRef $sCommandName)
	;Run CMD console command and wait until it finishes
	;---
	RunWait('"' &@ComSpec &'" /c ' &$sCommandName, @SystemDir)
EndFunc   ;==>run_cmd_wait

Func is_exe_running()
	;Returns PID if EXE is running. Returns 0 if not running.
	;---
	return (ProcessExists($server_exe))
EndFunc

Func stop_service()
	;Send STOP singal Windows Service
	;---
	local $sCommandName = "net stop " &$service_id & ""
	run_cmd_wait($sCommandName)
	Sleep(20000)
EndFunc   ;==>stop_service

Func start_service()
	;Send START singal Windows Service
	;---
	local $sCommandName = "net start " &$service_id &""
	run_cmd_wait($sCommandName)
	Sleep(20000)
EndFunc   ;==>start_service

Func verify_user_config($iShowConfig)
	;Verifies configuration data. show_config=1 -> Print config.
	;---
	; Find missing values in user config
	isempty_ini_value($service_id,"service_id")
	isempty_ini_value($server_name,"server_name")
	isempty_ini_value($server_dir,"server_dir")
	isempty_ini_value($server_exe,"server_exe")
	isempty_ini_value($app_id,"app_id")
	isempty_ini_value($steamcmd_dir,"steamcmd_dir")
	isempty_ini_value($steamcmd_exe,"steamcmd_exe")
	; Set default Steam username is not specified
	if $steam_user == "" Then $steam_user = "anonymous"
	ConsoleWrite("- NOTE: Steam username = Anonymous" &@CRLF)
	; Allow empty password for anonymous, else fail
	if $steam_pw == "" AND $steam_user <> "anonymous" Then isempty_ini_value($steam_pw,"steam_pw")
	isempty_ini_value($working_dir,"working_dir")
	ConsoleWrite("- User Configuration => Passed Verification" &@CRLF)
	; DEBUG: Print configuration
	if $iShowConfig = 1 Then
		ConsoleWrite("service_id = " &$service_id &@CRLF)
		ConsoleWrite("server_name = " &$server_name &@CRLF)
		ConsoleWrite("server_dir = " &$server_dir &@CRLF)
		ConsoleWrite("server_exe = " &$server_exe &@CRLF)
		ConsoleWrite("app_id = " &$app_id &@CRLF)
		ConsoleWrite("steamcmd_dir = " &$steamcmd_dir &@CRLF)
		ConsoleWrite("steamcmd_exe = " &$steamcmd_exe &@CRLF)
		ConsoleWrite("steam_user = " &$steam_user &@CRLF)
		local $sIniValue = ""
		$sIniValue = $steam_pw
		if $steam_user == "anonymous" then $sIniValue = ""
		ConsoleWrite("steam_pw = " &$steam_pw &@CRLF)
		ConsoleWrite("working_dir = " &$working_dir &@CRLF)
	EndIf
EndFunc



; === INI FUNCTIONS =========================
Func set_ini_path()
	; Get full path to INI from parameter1, or use the default
	;---
	local $sIniValue = ""
	if $CmdLine[0] > 0 Then	$sIniValue = $CmdLine[1] ; User specified INI file
	local $sIniValue = "SteamCMD-AutoUpdate.ini"  ; Default ini file name
	if not FileExists($sIniValue) then error_end("- ERROR9-FATAL: INI FILE NOT FOUND" &@CRLF &"-> Must be full path including filename. Default: " &$working_dir &"\SteamCMD-AutoUpdate.ini")
	return($sIniValue)
EndFunc

Func set_server_name()
	; Set default server name
	;---
	local $sIniValue = IniRead($g_sIniFilePath, "SERVER", "server_name", "Default Server")
	if $sIniValue == "" Then $sIniValue = "Default Server"
	Return($sIniValue)
EndFunc

Func set_steam_pw()
	; Remove Steam password if Steam user is anonymous
	;---
	local $sIniValue = IniRead($g_sIniFilePath, "SERVER", "steam_pw", "")
	if $steam_user == "anonymous" Then $sIniValue = ""
	Return $sIniValue
EndFunc

Func str_get_path($sFullPath)
	;Returns folder path from a full path. Eg: C:\folder\filename.txt ==> C:\folder\
	;---
	;debug: local $sFullPath = "C:\Program Files\Test Folder\filename.ini"
	local $aSplitStrings = StringSplit($sFullPath, "\")
	local $sReturn = ""
	local $i = 1
	local $sElements = $aSplitStrings[0]
	if $sElements <= 1 Then 
		error_end("- ERROR9-FATAL: BAD PATH" &@CRLF &"-> full_path must be a full path, including filename." &@CRLF &"-> " &$sFullPath)
	Else
		while $i < $sElements
			$sReturn &= $aSplitStrings[$i] & "\"
			$i = $i + 1
		WEnd
	EndIf
	Return $sReturn
EndFunc

Func str_get_filename($sFullPath)
	;Returns filename from a full path. Eg: C:\folder\filename.txt ==> filename.txt
	;---
	local $aSplitStrings = StringSplit($sFullPath, "\")
	local $sReturn = $aSplitStrings[$aSplitStrings[0]]
	Return $sReturn
EndFunc

Func isempty_ini_value($sIniValue, $sLabel)
	; Checks for missing values from INI file and exits
	;---
	if $sIniValue == "" Then 
		error_end("ERROR9-FATAL: INI CONFIG" &@CRLF &"->" &$sLabel &" = not specified" &@CRLF &"-->INI: " &$sIniFilePath)
	EndIf
EndFunc



; === ERROR HANDLE FUNCTIONS ==============================
;EXIT ERROR LEVELS:
; 1 = Service failed to stop
; 2 = SteamCMD errorlevel
; 3 = Service failed to start
; 9 = Misc errors
;---

Func error1()
	ConsoleWriteError("- ERROR1-FATAL: " &$server_name &" is still running!"  &@CRLF)
	ConsoleWriteError("-> Check the Windows Service and/or close " &$server_exe &" manually and try again."  & @CRLF)
	Exit(1)
EndFunc   ;==>error1

;Func error2()
;	ConsoleWriteError ( "- ERROR2-WARN: An unknown "& $steamcmd_exe &" error occured." & @CRLF)
;	ConsoleWriteError ( "-> "& $server_name &" may not have updated properly, check the logs." & @CRLF)
;	ConsoleWriteError ( "-> We did not automatically restart "& $server_exe &" ." & @CRLF)
;	Exit(2)
;EndFunc

Func error3()
	ConsoleWriteError("- ERROR3-WARN: " &$server_exe &" did not restart!" &@CRLF)
EndFunc   ;==>error3

Func error_end($sErrMsg)
	ConsoleWriteError($sErrMsg)
	Exit(9)
EndFunc    ;==>error_end
