; LOAD DATA FROM .INI FILE ==============
local $ini_value = ""
static global $iniFilePath = set_ini_path()
; Set gloabl configuration variables
static global $service_id = IniRead($iniFilePath, "SERVER", "service_id", "")
static global $server_name = IniRead($iniFilePath, "SERVER", "server_name", "Default Server")
; <server_dir: Split filename from full path specified in INI file
$ini_value = IniRead($iniFilePath, "SERVER", "server_dir", "")
static global $server_dir = str_get_path($ini_value)
static global $server_exe = str_get_filename($ini_value)
; />
static global $app_id = IniRead($iniFilePath, "SERVER", "app_id", "")
; <steam_cmd: Split filename from full path specified in INI file
$ini_value = IniRead($iniFilePath, "SERVER", "steamcmd_dir", "")
static global $steamcmd_dir = str_get_path($ini_value)
static global $steamcmd_exe = str_get_filename($ini_value)
; />
static global $steam_user = IniRead($iniFilePath, "SERVER", "steam_user", "anonymous")
static global $steam_pw = set_steam_pw(IniRead($iniFilePath, "SERVER", "steam_pw", ""))
static global $working_dir = IniRead($iniFilePath, "SERVER", "working_dir", "")

; Write console header
ConsoleWrite("==== Steam_CMD AUTO UPDATER =====================" &@CRLF)
ConsoleWrite("  Updating -" &$server_name &"- via SteamCMD ..." &@CRLF)
ConsoleWrite("=================================================" &@CRLF)

; Verify user specifed data
verify_user_config()

; STOP SERVER SERVICE
ConsoleWrite("- Stop Service: " &$service_id &"." &@CRLF)
if is_exe_running() Then stop_service()

; VERIFY SERVER HAS STOPPED
if is_exe_running() Then error1()

; UPDATE SERVER
ConsoleWrite("- Updating " &$server_name &@CRLF)
local $commandName = "" &$steamcmd_dir &"\" &$steamcmd_exe &" +force_install_dir "&$server_dir &"+login " &$steam_user &" " &$steam_pw &" +app_update " &$app_id &" -beta public validate +quit"
run_cmd_wait($commandName)

; RESTART SERVICE
ConsoleWrite("- Starting Service: "&$server_exe &"." &@CRLF)
start_service()
if NOT is_exe_running() Then error3()

; Write console footer
ConsoleWrite("==== UPDATE COMPLETED ===========================" & @CRLF)
Exit

; === ERROR HANDLE FUNCTIONS ==============================
Func error1()
	ConsoleWriteError("- ERROR1-FATAL: " &$server_name &" is still running!"  &@CRLF)
	ConsoleWriteError("- Check the Windows Service and/or close " &$server_exe &" manually and try again."  & @CRLF)
	Exit(1)
EndFunc   ;==>error1

;Func error2()
;	ConsoleWriteError ( "- ERROR2-WARN: An unknown "& $steamcmd_exe &" error occured." & @CRLF)
;	ConsoleWriteError ( "- "& $server_name &" may not have updated properly, check the logs." & @CRLF)
;	ConsoleWriteError ( "- We did not automatically restart "& $server_exe &" ." & @CRLF)
;	Exit(2)
;EndFunc

Func error3()
	ConsoleWriteError("- ERROR3: " &$server_exe &" did not restart!" &@CRLF)
EndFunc   ;==>error3


; === CUSTOM FUNCTIONS ===========================
Func run_cmd_wait(ByRef $commandName)
	; Run CMD console command and wait until it finishes
	RunWait('"' &@ComSpec &'" /c ' &$commandName, @SystemDir)
EndFunc   ;==>run_cmd_wait

Func is_exe_running()
	;Returns PID if EXE is running. Returns 0 if not running.
	return (ProcessExists($server_exe))
EndFunc

Func stop_service()
	;Send STOP singal Windows Service
	local $commandName = "net stop " &$service_id & ""
	run_cmd_wait($commandName)
	Sleep(20000)
EndFunc   ;==>stop_service

Func start_service()
	;Send START singal Windows Service
	local $commandName = "net start " &$service_id &""
	run_cmd_wait($commandName)
	Sleep(20000)
EndFunc   ;==>start_service

Func set_ini_path()
	; Get full path to INI from parameter1, or use the default
	local $ini_value = ""
	if $CmdLine[0] > 0 Then	$ini_value = $CmdLine[1] ; User specified INI file
	local $ini_value = "SteamCMD-AutoUpdate.ini"  ; Default ini file name
	return($ini_value)
EndFunc

Func verify_user_config()
	; Find missing values
	isempty_ini_value($service_id,"service_id")
	isempty_ini_value($server_name,"server_name")
	isempty_ini_value($server_dir,"server_dir")
	isempty_ini_value($server_exe,"server_exe")
	isempty_ini_value($app_id,"app_id")
	isempty_ini_value($steamcmd_dir,"steamcmd_dir")
	isempty_ini_value($steamcmd_exe,"steamcmd_exe")
	if $steam_user == "" Then $steam_user = "anonymous"
	ConsoleWrite("- NOTE: using Anonymous for Steam username" &@CRLF)
	;Empty password allowed for anonymous, else fail
	if $steam_pw == "" AND $steam_user <> "anonymous" Then isempty_ini_value($steam_pw,"steam_pw")
	isempty_ini_value($working_dir,"working_dir")
EndFunc

Func isempty_ini_value($iniValue, $label)
	; Checks for missing values from INI file and exits
	if $iniValue == "" Then 
		error_end("ERROR -> INI CONFIG!" &@CRLF &"->" &$label &" = not specified" &@CRLF &"-->INI: " &$iniFilePath)
	EndIf
EndFunc

Func set_steam_pw($ini_value)
	; Remove Steam password if Steam user is anonymous
	if $steam_user == "anonymous" Then $ini_value = ""
	Return $steam_pw = $ini_value
EndFunc

Func str_get_path($full_path)
	;Returns folder path from a full path. Eg: C:\folder\filename.txt ==> C:\folder\
	;local $full_path = "C:\Program Files\Test Folder\filename.ini"
	local $split_array = StringSplit($full_path, "\")
	local $return = ""
	local $i = 1
	local $elements = $split_array[0]
	if $elements <= 1 Then 
		ConsoleWrite("Bad path: Must be full path including filename.")
		$return("")
	Else
		while $i < $elements
			$return &= $split_array[$i] & "\"
			$i = $i + 1
		WEnd
	EndIf
	Return $return
EndFunc

Func str_get_filename($full_path)
	;Returns filename from a full path. Eg: C:\folder\filename.txt ==> filename.txt
	local $split_array = StringSplit($full_path, "\")
	local $return = $split_array[$split_array[0]]
	Return $return
EndFunc

Func error_end($err_msg)
	ConsoleWriteError($err_msg)
	Exit
EndFunc
