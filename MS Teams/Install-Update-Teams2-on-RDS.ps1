# Skript zum installieren oder aktualisieren von Teams 2 auf Terminalservern
# Stannek GmbH - v.1.1 - 28.03.2025 - E.Sauerbier

# Parameter
$UrlMSTeams = "https://go.microsoft.com/fwlink/?linkid=2196106"
$UrlBootstrapper = "https://go.microsoft.com/fwlink/?linkid=2243204"
$UrlNativeUtility = "https://statics.teams.cdn.office.net/evergreen-assets/DesktopClient/MSTeamsNativeUtility.msi"
$UrlEdgeWebView = 'https://go.microsoft.com/fwlink/?linkid=2124701'
$PathTeamsAddIn = Join-Path -Path $env:SystemDrive -ChildPath "Program Files (x86)\Microsoft\TeamsMeetingAddin"
$PathEdgeWebView = "C:\Program Files (x86)\Microsoft\EdgeWebView"
$WorkPath = If($PSISE){Split-Path -Path $psISE.CurrentFile.FullPath}else{Split-Path -Path $MyInvocation.MyCommand.Path}
IF ($Null -eq $WorkPath) {$WorkPath = Split-Path $psEditor.GetEditorContext().CurrentFile.Path} #Falls Skript in VS Code ausgefuehrt wird
$TEMPPath = Join-Path -Path $env:SystemDrive -ChildPath "Windows\Temp"

# Funktionen laden
Function Check-RunAsAdministrator()
{
  #Get current user context
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  #Check user is running the script is member of Administrator Group
  if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
       Write-host "Script is running with Administrator privileges!" -ForegroundColor Green
  }
  else
    {
       #Create a new Elevated process to Start PowerShell
       $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
 
       # Specify the current script path and name as a parameter
       $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
 
       #Set the Process to elevated
       $ElevatedProcess.Verb = "runas"
 
       #Start the new elevated process
       [System.Diagnostics.Process]::Start($ElevatedProcess)
 
       #Exit from the current, unelevated, process
       Exit
    }
}

# OS Version ermitteln
If ($((Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId).ReleaseId) -ge "2009") {$VersionOS = "202x"}
Else {$VersionOS = "2019"}

## Voraussetzungen checken

# NET 3.,x Feature checken, ist relevant fuer Meeting AddIn
If (((Get-WindowsFeature -Name NET-Framework-Features).InstallState) -ne "Installed") {Throw "NET 3.x Feature nicht aktiviert, bitte vorab aktivieren"}

# Checke ob Skript als Admin gestartet wurde
Check-RunAsAdministrator

# Teams 1 Komponenten entfernen, falls vorhanden
$OldTeams = try{Get-Package -Name "Teams Machine-Wide Installer" -ErrorAction SilentlyContinue}catch{$null}
    if ($OldTeams){
        Write-Host "entferne Teams Machine-Wide Installer" -ForegroundColor Yellow
        $OldTeamsPackage = ($OldTeams.FastPackageReference).ToString()
        Start-Process -NoNewWindow -FilePath "msiexec.exe" -ArgumentList "/X $OldTeamsPackage /qn /norestart" -Wait -ErrorAction SilentlyContinue -Verbose
        start-sleep -Seconds 10
        }

# Edge WebView installieren, falls noch nicht vorhanden
If (!(Test-Path -Path $PathEdgeWebView)) {
                Start-BitsTransfer -Source 'https://go.microsoft.com/fwlink/?linkid=2124701' -Destination "$TEMPPath\MicrosoftEdgeWebView2RuntimeInstallerX64.exe" -Description "Download latest EdgeWebView Runtime"
                Write-Host "`nInstall EdgeWebView Runtime. Please wait.`n"
                Start-Process -wait -FilePath "$InstallPath\MicrosoftEdgeWebView2RuntimeInstallerX64.exe" -Args "/silent /install" -Verbose
                }
Else {Write-Host "EdgeWebview Runtime bereits installiert" -ForegroundColor Green}

# Teams Meeting Add-In deinstallieren
$OldMeetingAddIn = try{get-package -Name 'Microsoft Teams Meeting Add-in*' -ErrorAction SilentlyContinue}catch{$null}
    if ($OldMeetingAddIn){
        Write-Host "entferne Microsoft Teams Meeting Add-in" -ForegroundColor Yellow
        $oldpackage = ($OldMeetingAddIn.FastPackageReference).ToString()
        Start-Process -NoNewWindow -FilePath "msiexec.exe" -ArgumentList "/X $oldpackage /qn /norestart" -Wait -ErrorAction SilentlyContinue -Verbose
        start-sleep -Seconds 10
        }

# Download und Update starten
If ($VersionOS -eq "202x") {
    ## Installation auf Server 202x
    # starte Download der Installer
    Start-BitsTransfer -Source $UrlMSTeams -Destination "$TEMPPath\MSTeams-x64.msix" -Description "Download latest Microsoft teams version" -Verbose
    Start-BitsTransfer -Source $UrlBootstrapper  -Destination "$TEMPPath\teamsbootstrapper.exe" -Description "Download teams bootstrapper" -Verbose

    # Installiere/Update Teams auf Server 202x
    Start-Process -wait -FilePath "$TEMPPath\teamsbootstrapper.exe" -Args "-p -o ""$TEMPPath\MSTeams-x64.msix""" -NoNewWindow -Verbose
    
    # Warten bis vollstaendig regstriert
     Start-Sleep -Seconds 15
    }
Else {
    ## Installation auf Server 2019 
    # starte Download der Installer
     Start-BitsTransfer -Source $UrlMSTeams -Destination "$TEMPPath\MSTeams-x64.msix" -Description "Download latest Microsoft teams version" -Verbose
     (New-Object Net.WebClient).DownloadFile($UrlNativeUtility,"$TEMPPath\MSTeamsNativeUtility.msi")

     # Installiere/Update NativeUtility auf Server 2019
     Start-Process "msiexec" -ArgumentList @("/i ""$TEMPPath\MSTeamsNativeUtility.msi""","/qn","/norestart ALLUSERS=1""") -Wait
     
     # Installiere/Update Teams auf Server 2019
     Start-Process -NoNewWindow -wait -FilePath DISM.exe -Args "/Online /Add-ProvisionedAppxPackage /PackagePath:$TEMPPath\MSTeams-x64.msix /SkipLicense" -Verbose

     # Warte bis fertig
     Start-Sleep -Seconds 45
    }

# Registry Keys fuer VDI und Citrix setzen
If (!(Test-Path -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Teams")) {New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Teams"}
New-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Teams" -Name "disableAutoUpdate" -Type dword  -Value 1 -force
New-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Teams" -Name "IsWVDEnvironment" -Type dword  -Value 1 -force
New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Citrix\WebSocketService" -Force
If (Test-Path -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Citrix") {New-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Citrix\WebSocketService" -Name "ProcessWhitelist" -Type MultiString  -Value "msedgewebview2.exe" -force}

# Laden der Informationen vom MS Teams Meeting AddIn
$MSTappx = (Get-AppxPackage | Where-Object -Property Name -EQ -Value MSTeams)
$MSTappxPath = $MSTappx.InstallLocation
$MSIname = "MicrosoftTeamsMeetingAddinInstaller.msi"
$MSTAddinMSI = Join-Path -Path $MSTappxPath -ChildPath $MSIName
$applockerinfo = (Get-AppLockerFileInformation -Path $MSTAddinMSI | Select-Object -ExpandProperty Publisher)
$MSTbinVer = $applockerinfo.BinaryVersion
$targetDir = "C:\Program Files (x86)\Microsoft\TeamsMeetingAddin\$MSTbinVer"

# erstelle Ordner und Log-File, falls noch nicht vorhanden
If (!(Test-Path $PathTeamsAddIn)) {New-Item -ItemType Directory -Path $PathTeamsAddIn -Verbose}
New-Item -ItemType File  "C:\Program Files (x86)\Microsoft\TeamsMeetingAddin\MSTMeetingAddin.log" -Force -Verbose

# Installiere MS Teams Meeting AddIn
Start-Process "msiexec" -ArgumentList @("/i ""$MSTAddinMSI""","/qn","/norestart ALLUSERS=1 TARGETDIR=""$targetDir"" /L*V ""C:\Program Files (x86)\Microsoft\TeamsMeetingAddin\MSTMeetingAddin.log""") -Wait -Verbose

# Registrieren vom MS Teams Meeting AddIn
Start-Process "c:\windows\System32\regsvr32.exe" -ArgumentList @("/s","/n","/i:user ""$targetDir\x64\Microsoft.Teams.AddinLoader.dll""") -wait -Verbose

# Bereinige Installer
Get-ChildItem -Path $($TEMPPath+"\*") -Include *.exe,*.msi,*.msix | Where-Object Name -like "*Teams*" | Remove-Item -Force -Verbose