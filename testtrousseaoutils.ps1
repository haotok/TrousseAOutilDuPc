# Vérifie si le script est exécuté avec des privilèges d'administrateur
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Relance le script en tant qu'administrateur
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File $($PSCommandPath)" -Verb RunAs
    exit
}
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "LA TROUSSE A OUTIL DU PC"
$form.Width = 1000
$form.Height = 650

function Show-MessageBox {
    param (
        [string]$message,
        [string]$title = "Message"
    )
    [System.Windows.Forms.MessageBox]::Show($message, $title, [System.Windows.Forms.MessageBoxButtons]::OK)
}

function Confirm-Action {
    param (
        [string]$message,
        [string]$title = "Confirmation"
    )
    $result = [System.Windows.Forms.MessageBox]::Show($message, $title, [System.Windows.Forms.MessageBoxButtons]::YesNo)
    return $result -eq [System.Windows.Forms.DialogResult]::Yes
}


# Affichage des informations système
function Show-SystemInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $ram = [math]::round($os.TotalVisibleMemorySize/1MB, 2)
    $ram_used = [math]::round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory)/1MB, 2)
    $info = @"
Système d'exploitation: $($os.Caption)
Version: $($os.Version)
Processeur: $($cpu.Name)
Utilisation de la RAM: $ram_used MB / $ram MB
"@
    Show-MessageBox $info "Informations système"
}

#VIDER LA CORBEILLE DU PC#
$button = New-Object System.Windows.Forms.Button
$button.Text = "VIDER LA CORBEILLE"
$button.Width = 100
$button.Height = 50
$button.Location = New-Object System.Drawing.Point(50, 50)
$button.ForeColor = [System.Drawing.Color]::Salmon
$button.Add_Click({
    if (Confirm-Action "Voulez-vous continuer?" "Titre") {
        try {
            Import-Module Microsoft.PowerShell.Management
            Clear-RecycleBin -Confirm:$false
            Show-MessageBox "La corbeille a été vidée avec succès."
        } catch {
            Show-MessageBox "Erreur lors de la vidange de la corbeille: $_"
        }
    } else {
        Show-MessageBox "Action annulée."
    }
})

#METTRE A JOUR LE PC#
#METTRE A JOUR LE PC#
$button2 = New-Object System.Windows.Forms.Button
$button2.Text = "METTRE A JOUR LE PC"
$button2.Width = 100
$button2.Height = 50
$button2.Location = New-Object System.Drawing.Point(150, 50)
$button2.ForeColor = [System.Drawing.Color]::Brown
$button2.Add_Click({
    Show-MessageBox "Mise à jour en cours, regardez votre console powershell pour voir où ça en est. CLIQUEZ SUR OK."
    try {
        Function Check-WindowsUpdate {
            [CmdletBinding()]
            param ()
            $Session = New-Object -ComObject Microsoft.Update.Session
            $Searcher = $Session.CreateupdateSearcher()
            $SearchResult = $Searcher.Search("IsInstalled=0 and Type='Software'")
            $UpdatesToDownload = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($Update in $SearchResult.Updates) {
                $UpdatesToDownload.Add($Update)
            }
            $Downloader = $Session.CreateUpdateDownloader()
            $Downloader.Updates = $UpdatesToDownload
            $Downloader.Download()
            $UpdatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
            foreach ($Update in $SearchResult.Updates) {
                $UpdatesToInstall.Add($Update)
            }
            $Installer = $Session.CreateUpdateInstaller()
            $Installer.Updates = $UpdatesToInstall
            $InstallationResult = $Installer.Install()
        }
        Check-WindowsUpdate
        Show-MessageBox "Le PC a été mis à jour! Mais on ne sait jamais allez voir comme même dans Windows Update."
        Start-Process "ms-settings:windowsupdate"
    } catch {
        Show-MessageBox "Erreur lors de la mise à jour du PC: $_"
    }
})


#METTRE A JOUR LA BASE DE DONNEE VIRALES#
$button3 = New-Object System.Windows.Forms.Button
$button3.Text = "METTRE A JOUR LA BASE DE DONNEE VIRALES"
$button3.Width = 130
$button3.Height = 70
$button3.Location = New-Object System.Drawing.Point(250, 50)
$button3.ForeColor = [System.Drawing.Color]::Violet
$button3.Add_Click({
    if (Confirm-Action "Voulez-vous continuer?" "Titre") {
        try {
            Update-MpSignature
            Show-MessageBox "La base de données virales a été mise à jour!"
        } catch {
            Show-MessageBox "Erreur lors de la mise à jour de la base de données virales: $_"
        }
    } else {
        Show-MessageBox "Action annulée."
    }
})

#LANCER CC CLEANER#
$button4 = New-Object System.Windows.Forms.Button
$button4.Text = "LANCER CC CLEANER"
$button4.Width = 130
$button4.Height = 70
$button4.Location = New-Object System.Drawing.Point(380, 50)
$button4.ForeColor = [System.Drawing.Color]::Magenta
$button4.Add_Click({
    if (Confirm-Action "Voulez-vous continuer?" "Titre") {
        try {
            Start-Process -filepath "C:\Program Files\CCleaner\CCleaner64.exe"
            Show-MessageBox "Et voici!"
        } catch {
            Show-MessageBox "Erreur lors du lancement de CCleaner: $_"
        }
    } else {
        Show-MessageBox "Action annulée."
    }
})

#LANCER UNE VERIFICATION ET REPARATION DES FICHIERS SYSTEMES EN INTEGRALE#
$button5 = New-Object System.Windows.Forms.Button
$button5.Text = "LANCER UNE VERIFICATION ET REPARATION DES FICHIERS SYSTEMES EN INTEGRALE"
$button5.Width = 190
$button5.Height = 100
$button5.Location = New-Object System.Drawing.Point(510, 50)
$button5.ForeColor = [System.Drawing.Color]::Orange
$button5.Add_Click({
    if (Confirm-Action "Voulez-vous continuer?" "Titre") {
        try {
            $params = @("/c", "sfc /scannow")
            $command = "cmd.exe"
            Start-Process -FilePath $command -ArgumentList $params -Verb RunAs
            Show-MessageBox "La vérification système intégrale a été lancée. Il est conseillé de ne pas fermer la fenêtre de commande pendant la vérification."
        } catch {
            Show-MessageBox "Erreur lors de la vérification des fichiers systèmes: $_"
        }
    } else {
        Show-MessageBox "Action annulée."
    }
})

#REPARER LES BUGS EN REPARANT L'IMAGE WINDOWS#
$button6 = New-Object System.Windows.Forms.Button
$button6.Text = "REPARER LES BUGS EN REPARANT L'IMAGE WINDOWS"
$button6.Width = 200
$button6.Height = 110
$button6.Location = New-Object System.Drawing.Point(700, 50)
$button6.ForeColor = [System.Drawing.Color]::Green
$button6.Add_Click({
    if (Confirm-Action "Voulez-vous continuer?" "Titre") {
        try {
            $params = @("/c", "dism /online /cleanup-image /restorehealth")
            $command = "cmd.exe"
            Start-Process -FilePath $command -ArgumentList $params -Verb RunAs
            Show-MessageBox "La réparation de l'image windows a été lancée. Il est conseillé de ne pas fermer la fenêtre de commande pendant la vérification."
        } catch {
            Show-MessageBox "Erreur lors de la réparation de l'image Windows: $_"
        }
    } else {
        Show-MessageBox "Action annulée."
    }
})

#LANCER UNE ANALYSE ANTIVIRUS RAPIDE#
$button7 = New-Object System.Windows.Forms.Button
$button7.Text = "LANCER UNE ANALYSE ANTIVIRUS RAPIDE"
$button7.Width = 150
$button7.Height = 110
$button7.Location = New-Object System.Drawing.Point(50, 120)
$button7.ForeColor = [System.Drawing.Color]::Blue
$button7.Add_Click({
    if (Confirm-Action "Voulez-vous continuer?" "Titre") {
        try {
            Show-MessageBox "Analyse rapide lancée... Regardez l'avancée du scan dans PowerShell. Appuyez sur OK."
            Start-MpScan -ScanType QuickScan
        } catch {
            Show-MessageBox "Erreur lors de l'analyse rapide: $_"
        }
    } else {
        Show-MessageBox "Action annulée."
    }
})

#LANCER UNE ANALYSE ANTIVIRUS COMPLETE#
$button8 = New-Object System.Windows.Forms.Button
$button8.Text = "LANCER UNE ANALYSE ANTIVIRUS COMPLETE"
$button8.Width = 150
$button8.Height = 110
$button8.Location = New-Object System.Drawing.Point(200, 120)
$button8.ForeColor = [System.Drawing.Color]::Red
$button8.Add_Click({
    if (Confirm-Action "Voulez-vous continuer?" "Titre") {
        try {
            Show-MessageBox "Analyse complète lancée... Regardez l'avancée du scan dans PowerShell. Appuyez sur OK."
            Start-MpScan -ScanType FullScan
        } catch {
            Show-MessageBox "Erreur lors de l'analyse complète: $_"
        }
    } else {
        Show-MessageBox "Action annulée."
    }
})

#LANCER MICROSOFT STORE ET METTRE A JOUR LES APPLICATIONS#
$button9 = New-Object System.Windows.Forms.Button
$button9.Text = "LANCER MICROSOFT STORE ET METTRE A JOUR LES APPLICATIONS"
$button9.Width = 160
$button9.Height = 110
$button9.Location = New-Object System.Drawing.Point(350, 120)
$button9.ForeColor = [System.Drawing.Color]::Indigo
$button9.Add_Click({
    if (Confirm-Action "Voulez-vous continuer?" "Titre") {
        try {
            Start-Process ms-windows-store:
            Show-MessageBox "Et voici!"
        } catch {
            Show-MessageBox "Erreur lors du lancement du Microsoft Store: $_"
        }
    } else {
        Show-MessageBox "Action annulée."
    }
})

#METTRE A JOUR LES PILOTES#
$button10 = New-Object System.Windows.Forms.Button
$button10.Text = "METTRE A JOUR LES PILOTES"
$button10.Width = 140
$button10.Height = 110
$button10.Location = New-Object System.Drawing.Point(510, 150)
$button10.Add_Click({
    try {
        $drivers = Get-WmiObject -Class Win32_PnPSignedDriver
        foreach ($driver in $drivers) {
            if ($driver.Status -eq "OK") {
                Update-Driver -Name $driver.DeviceName -Force -Verbose
            }
        }
        Show-MessageBox "Certains pilotes mis à jour. Pour les autres, veuillez aller dans Windows Update."
    } catch {
        Show-MessageBox "Erreur lors de la mise à jour des pilotes: $_"
    }
})

#REDEMARRER L'ORDINATEUR#
$button11 = New-Object System.Windows.Forms.Button
$button11.Text = "REDEMARRER L'ORDINATEUR"
$button11.Width = 150
$button11.Height = 140
$button11.Location = New-Object System.Drawing.Point(800, 400)
$button11.ForeColor = [System.Drawing.Color]::Teal
$font = New-Object System.Drawing.Font("Bodoni MT", 8, [System.Drawing.FontStyle]::Bold)
$button11.Font = $font
$button11.Add_Click({
    if (Confirm-Action "Voulez-vous continuer?" "Titre") {
        try {
            Restart-Computer
        } catch {
            Show-MessageBox "Erreur lors du redémarrage de l'ordinateur: $_"
        }
    } else {
        Show-MessageBox "Action annulée."
    }
})

#VERIFIER LE DISQUE DUR#
$button12 = New-Object System.Windows.Forms.Button
$button12.Text = "VERIFIER LE DISQUE DUR"
$button12.Width = 100
$button12.Height = 110
$button12.Location = New-Object System.Drawing.Point(50, 230)
$button12.ForeColor = [System.Drawing.Color]::Olive
$button12.Add_Click({
    try {
        $params = @("/c", "chkdsk /F /V")
        $command = "cmd.exe"
        Start-Process -FilePath $command -ArgumentList $params -Verb RunAs
    } catch {
        Show-MessageBox "Erreur lors de la vérification du disque dur: $_"
    }
})

#SUPPRIMER LES FICHIERS TEMPORAIRES DU DISQUE DUR#
$button13 = New-Object System.Windows.Forms.Button
$button13.Text = "SUPPRIMER LES FICHIERS TEMPORAIRES DU DISQUE DUR"
$button13.Width = 110
$button13.Height = 110
$button13.Location = New-Object System.Drawing.Point(150, 230)
$button13.ForeColor = [System.Drawing.Color]::Lime
$button13.Add_Click({
    if (Confirm-Action "Voulez-vous continuer?" "Titre") {
        try {
            Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force
            Show-MessageBox "Les fichiers temporaires ont été supprimés."
        } catch {
            Show-MessageBox "Erreur lors de la suppression des fichiers temporaires: $_"
        }
    } else {
        Show-MessageBox "Action annulée."
    }
})

#SUPPRIMER UN LOGICIEL DU PC#
$button14 = New-Object System.Windows.Forms.Button
$button14.Text = "SUPPRIMER UN LOGICIEL DU PC"
$button14.Width = 110
$button14.Height = 110
$button14.Location = New-Object System.Drawing.Point(260, 230)
$button14.ForeColor = [System.Drawing.Color]::RoyalBlue
$button14.Add_Click({
    Show-MessageBox "Veuillez aller dans la console PowerShell et taper un logiciel à désinstaller. CLIQUEZ SUR OK."
    $searchTerm = Read-Host "Enter search term for software to uninstall"
    try {
        $software1 = Get-AppxPackage | Where-Object { $_.Name -like "*$searchTerm*" }
        $software2 = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$searchTerm*" }
        if ($software1) {
            Remove-AppxPackage -Package $software1.PackageFullName
        }
        if ($software2) {
            $software2.Uninstall()
        }
        if (!$software1 -and !$software2) {
            Show-MessageBox "La désinstallation du logiciel n'a pas réussi. Je vais ouvrir le panneau de configuration où vous pourrez désinstaller ce logiciel..."
            Start-Process control appwiz.cpl
        } else {
            Show-MessageBox "Le logiciel a été désinstallé."
        }
    } catch {
        Show-MessageBox "Erreur lors de la désinstallation du logiciel: $_"
    }
})

#REPARER ET NETTOYER LE REGISTRE#
$button15 = New-Object System.Windows.Forms.Button
$button15.Text = "REPARER ET NETTOYER LE REGISTRE"
$button15.Width = 110
$button15.Height = 110
$button15.Location = New-Object System.Drawing.Point(370, 230)
$button15.ForeColor = [System.Drawing.Color]::Chocolate

$button15.Add_Click({
    if (Confirm-Action "Voulez-vous continuer?" "Titre") {
        try {
            # Nettoyage des clés de registre vides
            Get-ChildItem -Path "HKCU:\" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                if (!$_.GetValueNames() -and !$_.GetSubKeyNames()) {
                    Remove-Item -Path $_.PSPath -Force -ErrorAction SilentlyContinue
                }
            }

            # Nettoyage des références de DLL partagées manquantes
            Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDLLs" -ErrorAction SilentlyContinue | ForEach-Object {
                if (-not (Test-Path $_.PSPath)) {
                    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDLLs" -Name $_.Name -Force -ErrorAction SilentlyContinue
                }
            }

            # Nettoyage des extensions de fichiers non utilisées
            Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts" -ErrorAction SilentlyContinue | ForEach-Object {
                if (!$_.GetSubKeyNames()) {
                    Remove-Item -Path $_.PSPath -Recurse -Force -ErrorAction SilentlyContinue
                }
            }

            Show-MessageBox "Le registre a été nettoyé. Utilisez CCleaner pour un nettoyage plus approfondi si nécessaire."
        } catch {
            Show-MessageBox "Erreur lors de la réparation et du nettoyage du registre: $_"
        }
    } else {
        Show-MessageBox "Action annulée."
    }
})

# RECHERCHER QUELQUE CHOSE SUR LE DISQUE C: #
# Création du bouton
$button16 = New-Object System.Windows.Forms.Button
$button16.Text = "RECHERCHER QUELQUE CHOSE SUR LE DISQUE C:"
$button16.Width = 110
$button16.Height = 110
$button16.Location = New-Object System.Drawing.Point(50, 340)
$button16.ForeColor = [System.Drawing.Color]::Firebrick

# Ajout de l'événement Click au bouton
$button16.Add_Click({
    Show-MessageBox "Cet outil vous permettra de rechercher n'importe quoi sur le disque dur C:"

    try {
        # Demande du terme de recherche
        $searchTerm = $null
        while ($searchTerm -eq $null) {
            $searchTerm = Read-Host "Entrez le terme à rechercher"
            if ($searchTerm -eq "") {
                Write-Host "Veuillez entrer un terme de recherche valide"
                $searchTerm = $null
            }
        }

        # Utilisation de la recherche Windows pour effectuer la recherche plus rapidement
        $searchResults = Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -like "*$searchTerm*" -or $_.FullName -like "*$searchTerm*"
        }

        if ($searchResults) {
            # Afficher les résultats de la recherche
            $searchResults | ForEach-Object { Write-Host $_.FullName }
        } else {
            Show-MessageBox "Aucun fichier trouvé pour le terme '$searchTerm'."
        }
    } catch {
        Show-MessageBox "Erreur lors de la recherche sur le disque C: $_"
    }
})

#LANCER GLARY UTILITIES#
$button17 = New-Object System.Windows.Forms.Button
$button17.Text = "LANCER GLARY UTILITIES"
$button17.Width = 100
$button17.Height = 100
$button17.Location = New-Object System.Drawing.Point(160, 340)
$button17.ForeColor = [System.Drawing.Color]::Firebrick
$button17.Add_Click({
    try {
        Start-Process -filepath "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Glary Utilities\Glary Utilities.lnk"
        Show-MessageBox "Et voici!"
    } catch {
        Show-MessageBox "Erreur lors du lancement de Glary Utilities: $_"
    }
})

# Fonction pour afficher les informations système
function Show-SystemInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $ram = [math]::round($os.TotalVisibleMemorySize/1MB, 2)
    $ram_used = [math]::round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory)/1MB, 2)
    $info = @"
Système d'exploitation: $($os.Caption)
Version: $($os.Version)
Processeur: $($cpu.Name)
Utilisation de la RAM: $ram_used MB / $ram MB
"@
    [System.Windows.Forms.MessageBox]::Show($info, "Informations système")
}
# Création du bouton
$button18 = New-Object System.Windows.Forms.Button
$button18.Text = "Afficher les informations système"
$button18.Size = New-Object System.Drawing.Size(270, 50)
$button18.Location = New-Object System.Drawing.Point(250, 340)

# Ajout de l'événement 'Click' au bouton
$button18.Add_Click({ Show-SystemInfo })


$form.Controls.Add($button)
$form.Controls.Add($button2)
$form.Controls.Add($button3)
$form.Controls.Add($button4)
$form.Controls.Add($button5)
$form.Controls.Add($button6)
$form.Controls.Add($button7)
$form.Controls.Add($button8)
$form.Controls.Add($button9)
$form.Controls.Add($button10)
$form.Controls.Add($button11)
$form.Controls.Add($button12)
$form.Controls.Add($button13)
$form.Controls.Add($button14)
$form.Controls.Add($button15)
$form.Controls.Add($button16)
$form.Controls.Add($button17)
$form.Controls.Add($button18)
$form.ShowDialog()
