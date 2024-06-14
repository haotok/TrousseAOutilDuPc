###### Ouvrir les options du pare feu ######

Add-Type -AssemblyName System.Windows.Forms

# Création du formulaire principal
$form = New-Object System.Windows.Forms.Form
$form.Text = "Sécurité du système, que souhaitez-vous réparer?"
$form.Size = New-Object System.Drawing.Size(750,500) # J'ai légèrement augmenté la largeur pour s'adapter aux boutons
$form.StartPosition = 'CenterScreen'

# Création d'un bouton pour ouvrir le pare-feu Windows Defender
$openFirewallButton = New-Object System.Windows.Forms.Button
$openFirewallButton.Location = New-Object System.Drawing.Point(50, 100) # J'ai déplacé un peu plus à gauche pour s'adapter aux deux boutons
$openFirewallButton.Size = New-Object System.Drawing.Size(200,40)
$openFirewallButton.Text = "Ouvrir le pare-feu Windows Defender"
$openFirewallButton.Add_Click({
    Start-Process "control.exe" -ArgumentList "firewall.cpl"
})
$form.Controls.Add($openFirewallButton)


##### Ouvrir Windows Defender ######

$openDefenderButton = New-Object System.Windows.Forms.Button
$openDefenderButton.Location = New-Object System.Drawing.Point(260, 100) # Positionné à côté du premier bouton
$openDefenderButton.Size = New-Object System.Drawing.Size(200,40)
$openDefenderButton.Text = "Ouvrir Windows Defender"
$openDefenderButton.Add_Click({
    Start-Process "ms-settings:windowsdefender"
})
$form.Controls.Add($openDefenderButton)


##### Ouvrir Windows Update #####

$openUpdateButton = New-Object System.Windows.Forms.Button
$openUpdateButton.Location = New-Object System.Drawing.Point(50, 50)
$openUpdateButton.Size = New-Object System.Drawing.Size(200,40)
$openUpdateButton.Text = "Ouvrir Windows Update"
$openUpdateButton.Add_Click({
    Start-Process "ms-settings:windowsupdate"
})
$form.Controls.Add($openUpdateButton)


##### Ouvrir la gestion des utilisateurs du PC #####

$openUserButton = New-Object System.Windows.Forms.Button
$openUserButton.Location =  New-Object System.Drawing.Point(260, 50)
$openUserButton.Size = New-Object System.Drawing.Size(200,40)
$openUserButton.Text = "Ouvrir la gestion des utilisateurs du PC"
$openUserButton.Add_Click({
    Start-Process "control.exe" -ArgumentList "userpasswords2" -Verb runAs
})

$form.Controls.Add($openUserButton)


##### Ouvrir la gestion de l'ordinateur #####

$openGestionOrdiButton = New-Object System.Windows.Forms.Button
$openGestionOrdiButton.Location = New-Object System.Drawing.Point(470, 50)
$openGestionOrdiButton.Size = New-Object System.Drawing.Size(200,40)
$openGestionOrdiButton.Text = "Ouvrir la gestion de l'ordinateur"
$openGestionOrdiButton.Add_Click({
    Start-Process "compmgmt.msc" -Verb runAs
})

$form.Controls.Add($openGestionOrdiButton)


##### Ouvrir les paramètres de contrôle de compte utilisateurs #####

$openusercontrol = New-Object System.Windows.Forms.Button
$openusercontrol.Location = New-Object System.Drawing.Point(470, 100)
$openusercontrol.Size = New-Object System.Drawing.Size(200,40)
$openusercontrol.Text = "Ouvrir les paramètres de contrôle des utilisateurs"
$openusercontrol.Add_Click({
    Start-Process "UserAccountControlSettings.exe"
})

$form.Controls.Add($openusercontrol)


##### Ouvrir les paramètres de BitLocker #####

$openBitLockerParam = New-Object System.Windows.Forms.Button
$openBitLockerParam.Location = New-Object System.Drawing.Point(50, 150)
$openBitLockerParam.Size = New-Object System.Drawing.Size(200,40)
$openBitLockerParam.Text = "Ouvrir les paramètres de BitLocker"
$openBitLockerParam.Add_Click({
    Start-Process "control" -ArgumentList "BitLockerDriveEncryption"
})

$form.Controls.Add($openBitLockerParam)

# Affichage du formulaire
$form.ShowDialog()
        