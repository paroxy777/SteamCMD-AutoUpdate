<html>
  <h1>SteamCMD-AutoUpdate</h1>
  <p><b>Easy Steam dedicated game server updates & local installtion repair.</b></p>
  
  <p>This project is to a simple way to upgrade any dedicatied game server that was installed via Steam or SteamCMD.<br>
    SteamCMD will verify your local installtion files and install any recent updates.
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
    <li>Execuable console app (.exe compiled from .au3)</li>
  </ul>
  <h2>Installtion</h2>
  <p>Files required for each version:</p>
  <ul>
    <li>.CMD version: SteamCMD-AutoUpdate.cmd</li>
    <li>.AU3 version: SteamCMD-AutoUpdate.au3 & SteamCMD-AutoUpdate.ini</li>
    <li>.EXE version: SteamCMD-AutoUpdate.exe & SteamCMD-AutoUpdate.ini</li>
  <h2>Usage</h2>
  <ol>
    <li>Edit the configuration at the top of the .cmd file <b>-OR-</b> Edit the .ini file for the .au3 or .exe versions.</li>
    <li>Run as Administrator. This is required for the Windows Service stop/start controls.</li>
  </ol>
</html>
