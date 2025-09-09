$certs=get-childitem -path cert:/LocalMachine/My
foreach ($c in $certs) {   
    if ($c.Subject.IndexOf("CN=*.") -eq 0) {
        write-host -ForegroundColor Yellow  $c.Subject
        $t=[string]$c.thumbprint
		Set-WmiInstance -Path ((Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'").__path) -argument @{SSLCertificateSHA1Hash=$t
        # WMIC ist ab Server 2025 nicht mehr funktional, da abgekuendigt
		#wmic /namespace:\\root\CIMV2\TerminalServices PATH Win32_TSGeneralSetting Set SSLCertificateSHA1Hash=$t 
    } 
}
}