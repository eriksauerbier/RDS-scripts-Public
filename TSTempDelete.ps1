# Terminalserver TEMP Delete Skript
# Stannek GmbH v.1.1 - 26.09.2022 - E.Sauerbier

# IE Cache für alle User

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Microsoft\Windows\INetCache") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Microsoft\Windows\INetCache\Low\IE") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Microsoft\Windows\Temporary Internet Files\*") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

# FireFox Cache für alle User

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\*") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries\*.*") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails\*") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Mozilla\Firefox\Profiles\*.default\cookies.sqlite") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Mozilla\Firefox\Profiles\*.default\webappsstore.sqlite") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Mozilla\Firefox\Profiles\*.default\chromeappsstore.sqlite") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

# Chrome Cache für alle User

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Google\Chrome\User Data\Default\Cookies") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Google\Chrome\User Data\Default\Cache\*") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Google\Chrome\User Data\Default\Cache2\entries\*") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Google\Chrome\User Data\Default\Cookies-Journal") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

# Edge Cache für alle User


foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Microsoft\Edge\User Data\Default\Cookies") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Microsoft\Edge\User Data\Default\Cache\*") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Microsoft\Edge\User Data\Default\Cache2\entries\*") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\Microsoft\Edge\User Data\Default\Cookies-Journal") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

# User Temp

foreach($folder in (Get-Childitem "C:\Users\")) {
	Get-ChildItem -Path ($folder.FullName+"\AppData\Local\temp\*") -Recurse | Remove-Item -Force -Recurse | Out-Null
}

# Windows Temp

Remove-Item -Force -Recurse -Path C:\Windows\Temp\*

# Admin Download

Remove-Item -Force -Recurse -Path C:\Users\Administrator*\Downloads\* -Exclude desktop.ini
Remove-Item -Force -Recurse -Path C:\Users\DATEVADMIN*\Downloads\* -Exclude desktop.ini

# Adobe Vorschaubilder löschen

Get-ChildItem C:\Users |%{Remove-Item -Path "C:\Users\$_\AppData\LocalLow\Adobe\Acrobat\DC\ConnectorIcons\*" -Force -Recurse}