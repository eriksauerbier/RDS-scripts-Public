# Skript zum Sperren von RD-Sessionhosts
# Stannek GmbH - v.1.2 - 08.06.2022 - E.Sauerbier, G.Werner

## Funktionen laden

# Funktion zum Sperren der ausgewählten SessionHosts
function Set-SessionHostLogonState() 
{
    $Ausgabe=''
    $controls=$objForm.controls
    $controls.count
    foreach ($co in $controls) {
        #write-host $co.name
        if ($co.Name -like "Checkbox*") {
            if ($co.Checked) { 
                $Ausgabe=$Ausgabe + $co.Text + ' ist gesperrt' + [environment]::NewLine
                Set-RDSessionHost -ConnectionBroker $Broker -SessionHost $co.Text -NewConnectionAllowed No
            }
            else {
                $Ausgabe=$Ausgabe + $co.Text + ' ist freigegeben' + [environment]::NewLine
                Set-RDSessionHost -ConnectionBroker $Broker -SessionHost $co.Text -NewConnectionAllowed Yes
            }
        }
    }
    [System.Windows.Forms.MessageBox]::Show($Ausgabe , 'Fertig') 
}

# Funktion zur Auswahl der RD-Collection (Farm)
function Select-RDCollection() 
{
    $Global:Cancel = $false
    $controls=$objForm.controls
    $controls.count
    foreach ($co in $controls) {
        if ($co.Name -like "Checkbox*") {
            if ($co.Checked) { 
                # gewählte RD-Collection setzen
                $Global:Collection = $Null
                $Global:Collection += $co.Text
            }
        }
    }
    # Falls nichts ausgewählt wurde bricht das Skript ab
    if ($Global:Collection.Count -gt "1") {$Global:Cancel = "Error"}
}

function exit-Script(){
  $Global:Cancel = "Cancel"
  $objForm.Close()
}

## Funktionen laden Ende

# Assemblys laden
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# Globale Abbruch-Variable zurücksetzen
$Global:Cancel = $false

# Broker auslesen
$Broker = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\ClusterSettings" -Name "SessionDirectoryLocation").SessionDirectoryLocation

# Registry auslesen ob es sich um Sessionhost handelt
$associatedCollection = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\ClusterSettings" -Name "SessionDirectoryClusterName").SessionDirectoryClusterName

# Abfrage des Farmnamens je nach Typ des ausführenden Servers (Sessionhost / Connectionbroker)
If ($associatedCollection -ne "") {#Farmnamen vom Sessionhost
      $Global:Collection = $associatedCollection
      }
Else {# Abfrage des Farmnamens am ConnectionBroker
      $Global:Collection = Get-RDSessionCollection -ConnectionBroker $Broker | Select-Object -ExpandProperty CollectionName
     }


# Falls mehr als eine Farm existiert dann wird die Farm abgefragen
## Abfrage Farm
if ($Global:Collection.Count -gt 1) 
    {
    $objForm = New-Object System.Windows.Forms.Form
    $objForm.Backcolor='lightblue'
    $objForm.StartPosition = "CenterScreen"
    $objForm.Size = New-Object System.Drawing.Size(300,160)
    $objForm.Text = "TSFarm auswählen"

    # X1 linker Rand, X2=linker Rand Eingabefelder, H = Höhe
    $X1=10
    $X2=150
    $H=20


    $objLabel = New-Object System.Windows.Forms.Label
    $objLabel.Location = New-Object System.Drawing.Point($x1,20)
    $objLabel.Size = New-Object System.Drawing.Size(100,$H)
    $objLabel.Text = 'Bitte Farm wählen:'
    $objForm.Controls.Add($objLabel)
    $i=0
    for ($i=0;$i -lt $Global:Collection.count; $i++) {
    $objCheckbox= New-Object System.Windows.Forms.Checkbox 
    $objCheckbox.Name="Checkbox" + $i
    $y=20+($i*20)
    $obj=$objCheckbox.Location = New-Object System.Drawing.Size($x2,$y) 
    $objCheckbox.Size = New-Object System.Drawing.Size(200,20)
    $objCheckbox.Text = $Global:Collection[$i]
    $objCheckbox.TabIndex = $i
    $objForm.Controls.Add($objCheckbox) 
    }
        # ----------------- Formular-Buttons ----------------------------------

    $OKButton = New-Object System.Windows.Forms.Button
    # Die nächsten beiden Zeilen legen die Position und die Größe des Buttons fest
    $OKButton.Location = New-Object System.Drawing.Point($X1,80)
    $OKButton.Size = New-Object System.Drawing.Size(100,30)
    $OKButton.Text = "OK"
    $OKButton.Name = "OK"
    $OKButton.BackColor=1
    $OKButton.DialogResult = "OK"
    # Mit drücken der OK-Taste wird die Funktion zur RD-Collection auswahl ausgeführt
    $OKButton.Add_Click({Select-RDCollection})
    $objForm.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    # Die nächsten beiden Zeilen legen die Position und die Größe des Buttons fest
    $CancelButton.Location = New-Object System.Drawing.Point($x2,80)
    $CancelButton.Size = New-Object System.Drawing.Size(100,30)
    $CancelButton.Text = "Abbrechen"
    $CancelButton.Name = "Abbrechen"
    $CancelButton.BackColor=1
    $CancelButton.DialogResult = "Cancel"
    # Mit drücke der Cancel-Taste wird das Skript beendet
    $CancelButton.Add_Click({Exit-Script})
    $objForm.Controls.Add($CancelButton)

    [void] $objForm.ShowDialog()

    # Skript abbrechen, wenn Abbrechen geklickt wurde  
    if (($Global:Cancel -eq "Cancel") -or ($Global:Cancel -eq "Error")){Write-Host $Global:Cancel -ForegroundColor RED; break}       
    }
## Abfrage Farm Ende


# Abfrage der Sessionshost innerhalb der Farm
$RDSH=Get-RDSessionHost -ConnectionBroker $Broker -CollectionName $Global:Collection | Sort-Object SessionHost

#-------------------------------------------------------------------------------------------
# Formular
#-------------------------------------------------------------------------------------------

# Formular Grundeinstellungen festlegen
$objForm = New-Object System.Windows.Forms.Form
$objForm.Backcolor='lightblue'
$objForm.StartPosition = "CenterScreen"
$objForm.Size = New-Object System.Drawing.Size(400,300)
$objForm.Text = "WTS-Anmeldung sperren"

# X1 linker Rand, X2=linker Rand Eingabefelder, H = Höhe
$X1=10
$X2=150
$x3=600
$H=20

# Formularfelder definieren

# Feld: Brokerserver
$objLabel1 = New-Object System.Windows.Forms.Label
$objLabel1.Location = New-Object System.Drawing.Point($x1,20)
$objLabel1.Size = New-Object System.Drawing.Size(80,$H)
$objLabel1.Text = 'Brokerserver:'
$objForm.Controls.Add($objLabel1)
$objBroker=New-Object System.Windows.Forms.Textbox
$objBroker.Location = New-Object System.Drawing.Point($x2,20)
$objBroker.Size = New-Object System.Drawing.Size(180,$H)
$objBroker.Text=$Broker
$objForm.Controls.Add($objBroker)

# Feld: Collection
$objLabel2 = New-Object System.Windows.Forms.Label
$objLabel2.Location = New-Object System.Drawing.Point($x1,50)
$objLabel2.Size = New-Object System.Drawing.Size(80,$H)
$objLabel2.Text = 'WTS-Farm:'
$objForm.Controls.Add($objLabel2)
$objFarm=New-Object System.Windows.Forms.Textbox
$objFarm.Location = New-Object System.Drawing.Point($x2,50)
$objFarm.Size = New-Object System.Drawing.Size(180,$H)
$objFarm.Text=$Global:Collection
$objForm.Controls.Add($objFarm)

# Feld: SessionHost
$objLabel3 = New-Object System.Windows.Forms.Label
$objLabel3.Location = New-Object System.Drawing.Point($x1,80)
$objLabel3.Size = New-Object System.Drawing.Size(300,$H)
$objLabel3.Text = 'Bitte zu sperrende Terminalserver wählen:'
$objForm.Controls.Add($objLabel3)

# SessionHosts anhand der Anzahl hinzufügen
$i=0
for ($i=0;$i -lt $RDSH.Count; $i++) {
    $objCheckbox= New-Object System.Windows.Forms.Checkbox 
    $objCheckbox.Name="Checkbox" + $i
    $y=100+($i*20)
    $obj=$objCheckbox.Location = New-Object System.Drawing.Size($x2,$y) 
    $objCheckbox.Size = New-Object System.Drawing.Size(200,20)
    $objCheckbox.Text = $RDSH[$i].SessionHost
    $objCheckbox.Checked = $RDSH[$i].NewConnectionAllowed
    $objCheckbox.TabIndex = $i
    $objForm.Controls.Add($objCheckbox)       
}


# ----------------- Formular-Buttons ----------------------------------

$OKButton = New-Object System.Windows.Forms.Button
# Die nächsten beiden Zeilen legen die Position und die Größe des Buttons fest
$OKButton.Location = New-Object System.Drawing.Point($X1,220)
$OKButton.Size = New-Object System.Drawing.Size(100,30)
$OKButton.Text = "OK"
$OKButton.Name = "OK"
$OKButton.BackColor=1
$OKButton.DialogResult = "OK"
# Mit drücken der OK-Taste wird die Funktion zum setzen des Anmeldestatus ausgeführt
$OKButton.Add_Click({Set-SessionHostLogonState})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
# Die nächsten beiden Zeilen legen die Position und die Größe des Buttons fest
$CancelButton.Location = New-Object System.Drawing.Point($x2,220)
$CancelButton.Size = New-Object System.Drawing.Size(100,30)
$CancelButton.Text = "Abbrechen"
$CancelButton.Name = "Abbrechen"
$CancelButton.BackColor=1
$CancelButton.DialogResult = "Cancel"
# Mit drücken der Cancel-Taste wird das Skript beendet
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

# Formular ausgeben
[void] $objForm.ShowDialog()

#-------------------------------------------------------------------------------------------
# Formular Ende
#-------------------------------------------------------------------------------------------

# Skript beenden
Exit

