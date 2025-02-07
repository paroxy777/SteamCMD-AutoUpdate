<html>
  <h1>SteamCMD-AutoUpdate</h1>
  <p><b>Easy Steam dedicated game server updates & local installtion repair.</b></p>
  
  <p>This project is to a simple way to upgrade any dedicatied game server that was installed via Steam or SteamCMD. SteamCMD will verify your local installtion files and install any recent updates.
  <p>This is all highly experimental. There are no destructive functions, but use at your own risk.</p>
  
  <h2>Theroy of operation</h2>
  <ol>
    <li>Stop the running server gracefully</li>
    <li>Verify the server process has quit</li>
    <li>Run the SteamCMD command to perform the update</li>
    <li>Restart the server process</li>
    <li>Verify the server process has restarted</li>
  </ol>
  
  <h2>3rd Party Requirements</h2>
  <ul>
    <li><a href="https://developer.valvesoftware.com/wiki/SteamCMD">SteamCMD</a></li>
    <li>A Windows Service for the dedicated server. This can be done easily with <a href="https://nssm.cc/">NSSM</a>, or <a href="https://stackoverflow.com/questions/3582108/create-windows-service-from-executable">manually</a> if you prefer.</li>
  </ul>
  
  <h2>Builds available</h2>
  <ul>
    <li>Windows CMD batch file (.cmd)</li>
    <li><a href="https://www.autoitscript.com/site/">AutoIt</a> script (.au3)</li>
    <li>Execuable console app (.exe is directly compiled from the .au3 source file)</li>
  </ul>
  <h2>Installation</h2>
  <p>Files required for each version:</p>
  <ul>
    <li><b>.CMD version:</b> SteamCMD-AutoUpdate.cmd</li>
    <li><b>.AU3 version:</b> SteamCMD-AutoUpdate.au3 & SteamCMD-AutoUpdate.ini</li>
    <li><b>.EXE version:</b> SteamCMD-AutoUpdate.exe & SteamCMD-AutoUpdate.ini</li>
  </ul>
  <h2>Usage</h2>
  <h3>CMD Version:</h3>
  <ol>
    <li>Edit the User Configuration area at the top of the .cmd file.</li>
    <li>Run as Administrator. This is required for the Windows Service stop/start controls.</li>
  </ol>
  <h3>AU3 or .EXE Version:</h3>
  <ol>
    <li>Edit the .INI to match your server's configuration.</li>
    <li>Run as Administrator. This is required for the Windows Service stop/start controls.</li>
  </ol>
  <h2>Managing multiple dedicated servers</h2>
  <h3>CMD version:</h3>
  <p>1. Make multiple copies the SteamCMD-AutoUpdate.cmd and modify the User Configuration section in each file.</p>
  <p>2. Run the .CMD file for the dedicated server you wish.</p>
  <h3>AU3 or EXE version:</h3>
  <p>1. Create a copy of the SteamCMD-AutoUpdate.ini file and modify it for each dedicated server.</p>
  <p>2. Pass the name of the .INI file to the script:</p>
  <pre>SteamCMD-AutoUpdate.exe myCustomFile.ini</pre>
  <p>Plan B:</p>
  <p>Make copies of the the required files into separate directories and modify each SteamCMD-AutoUpdate.ini file.</p>
</html>
