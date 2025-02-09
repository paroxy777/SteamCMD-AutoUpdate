; LOAD DATA FROM .INI FILE ==============
; Get ini file location from command line parameter, or use the default
local $parma1 = "SteamCMD-AutoUpdate.ini"  ; Default ini file name
if $CmdLine[0] > 0 Then	$parma1 = $CmdLine[1]
local const $iniFilePath = $parma1

; Set configuration variables
static global $service_name = IniRead($iniFilePath, "SERVER", "service_name", "")
static global $server_name = IniRead($iniFilePath, "SERVER", "server_name", "")
static global $app_id = IniRead($iniFilePath, "SERVER", "app_id", "")
static global $steam_user = IniRead($iniFilePath, "SERVER", "steam_user", "anonymous")
static global $working_dir = IniRead($iniFilePath, "SERVER", "working_dir", "")
; Split File name and Path from full path specified in INI file
local $ini_value = IniRead($iniFilePath, "SERVER", "server_dir", "")
static global $server_dir = str_get_path($ini_value)
static global $server_exe = str_get_filename($ini_value)
; Split File name and Path from full path specified in INI file
$ini_value = IniRead($iniFilePath, "SERVER", "steamcmd_dir", "")
static global $steamcmd_dir = str_get_path($ini_value)
static global $steamcmd_exe = str_get_filename($ini_value)
; Remove Steam password if Steam user is anonymous
$ini_value = IniRead($iniFilePath, "SERVER", "steam_pw", "")
if $steam_user == "anonymous" Then $ini_value = ""
static global $steam_pw = $ini_value

; MAIN PROGRAM ========================
; BEGIN
if $steam_user == "" Then $steam_user = "anonymous"
ConsoleWrite("- Updating " & $server_name & " ..." & @CRLF)

; STOP SERVER SERVICE
ConsoleWrite("- Stop Service: " & $service_name & "." & @CRLF)
if is_exe_running() Then stop_service()

; VERIFY SERVER HAS STOPPED
if is_exe_running() Then error1()

; UPDATE SERVER
ConsoleWrite("- Updating " & $server_name & @CRLF)
local $commandName = ""& $steamcmd_dir & "\" & $steamcmd_exe & " +force_install_dir " & $server_dir & " +login " & $steam_user &" "& $steam_pw & " +app_update " & $app_id & " -beta public validate +quit"
run_cmd_wait($commandName)

; END
ConsoleWrite("- Starting Service: "& $server_exe & "." & @CRLF)
start_service()
if NOT is_exe_running() Then error3()
ConsoleWrite("- UPDATE COMPLETED" & @CRLF)
Exit

; ERRORS ==============================
Func error1()
	ConsoleWriteError("- ERROR1-FATAL: " & $server_name & " is still running!"  & @CRLF)
	ConsoleWriteError("- Check the Windows Service and/or close " & $server_exe & " manually and try again."  & @CRLF)
	Exit(1)
EndFunc   ;==>error1

;Func error2()
;	ConsoleWriteError ( "- ERROR2-WARN: An unknown "& $steamcmd_exe &" error occured." & @CRLF)
;	ConsoleWriteError ( "- "& $server_name &" may not have updated properly, check the logs." & @CRLF)
;	ConsoleWriteError ( "- We did not automatically restart "& $server_exe &" ." & @CRLF)
;	Exit(2)
;EndFunc

Func error3()
	ConsoleWriteError("- ERROR3: " & $server_exe & " did not restart!" & @CRLF)
EndFunc   ;==>error3

; FUNCTIONS ===========================
Func run_cmd_wait(ByRef $commandName)
	; Run CMD console command and wait until it finishes
	RunWait('"' & @ComSpec & '" /c ' & $commandName, @SystemDir)
EndFunc   ;==>run_cmd_wait

Func is_exe_running()
	;Returns PID if EXE is running. Returns 0 if not running.
	return (ProcessExists($server_exe))
EndFunc

Func stop_service()
	;Send STOP singal Windows Service
	local $commandName = "net stop "& $service_name & ""
	run_cmd_wait($commandName)
	Sleep(20000)
EndFunc   ;==>stop_service

Func start_service()
	;Send START singal Windows Service
	local $commandName = "net start "& $service_name & ""
	run_cmd_wait($commandName)
	Sleep(20000)
EndFunc   ;==>start_service

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
