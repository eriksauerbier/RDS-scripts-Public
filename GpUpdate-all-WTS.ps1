# Gruppenrichtlinien aktualisieren für alle Terminalserver eines Brokers
# (c) by Gerald Werner 25.07.2024

# Broker und Farmname auslesen
$Broker = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\ClusterSettings" -Name "SessionDirectoryLocation").SessionDirectoryLocation
$Global:Collection = Get-RDSessionCollection -ConnectionBroker $Broker | Select-Object -ExpandProperty CollectionName
$associatedCollection = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\ClusterSettings" -Name "SessionDirectoryClusterName").SessionDirectoryClusterName
$Global:Cancel = $false

# Wenn Skript am Sessionhost ausgeführt wird, kommt keine Farmabfrage
if ($associatedCollection -ne "") {$Global:Collection = $associatedCollection}


# Abfrage der Sessionshost innerhalb der Farm
$RDSH=Get-RDSessionHost -ConnectionBroker $Broker -CollectionName $Global:Collection
cls
foreach ($h in $rdsh) {
    write-host "Gruppenrichtlinien aktualisieren auf" $h.SessionHost -ForegroundColor Yellow
    invoke-command -computername $h.SessionHost -scriptblock {gpupdate /force}
}

Write-Host "Erledigt!" -ForegroundColor Green
pause

