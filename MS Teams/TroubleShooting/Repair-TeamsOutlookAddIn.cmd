Rem "Der Pfad muss pro Kunde entsprechend angepasst werden (AddIn Version und Outlook Architektur)
Echo "Bitte Outlook schliessen und beliebige Taste druecken"
Pause
%SystemRoot%\System32\regsvr32.exe /n /i:user "C:\Program Files (x86)\Microsoft\TeamsMeetingAddin\1.24.31301.0\x86\Microsoft.Teams.AddinLoader.dll"