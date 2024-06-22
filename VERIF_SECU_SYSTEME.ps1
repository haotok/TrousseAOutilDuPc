# Charger les assemblies nécessaires
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Créer le formulaire
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Windows Defender Extension'
$form.Size = New-Object System.Drawing.Size(500,600)

# Ajouter une barre de progression
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(50,300)
$progressBar.Size = New-Object System.Drawing.Size(300,20)

$form.Controls.Add($progressBar)

# Ajouter le titre
$label = New-Object System.Windows.Forms.Label
$label.Text = "BIENVENUE SUR WINDOWS DEFENDER EXTENSION"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(40,20)
$form.Controls.Add($label)


$bytes = [Convert]::FromBase64String($base64ImageString)
$memoryStream = New-Object System.IO.MemoryStream($bytes, 0, $bytes.Length)
$memoryStream.Write($bytes, 0, $bytes.Length)
$image = [System.Drawing.Image]::FromStream($memoryStream)

$pictureBox = New-Object Windows.Forms.PictureBox
$pictureBox.Size = $image.Size
$pictureBox.Image = $image

# Et ensuite, ajoutez $pictureBox à votre formulaire comme d'habitude.

# Charger l'image localement
$image = [System.Drawing.Image]::FromFile($imagePath)

$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.Size = New-Object System.Drawing.Size(320,240)
$pictureBox.Location = New-Object System.Drawing.Point(40,60)
$pictureBox.SizeMode = 'Zoom'
$pictureBox.Image = $image
$form.Controls.Add($pictureBox)

# Ajouter un bouton Start
$startButton = New-Object System.Windows.Forms.Button
$startButton.Text = "START"
$startButton.Location = New-Object System.Drawing.Point(150,320)
$startButton.Add_Click({

$progressBar.Minimum = 0
$progressBar.Maximum = 17 # Nombre total d'étapes dans le script
$progressBar.Value = 0

# _______________________________________Vérification de la sécurité système avec PowerShell__________________________________________________________

"----- VERIFICATION DE LA SECURITE DU SYSTEME -----" | Out-File -FilePath $chemin

##### Vérifier si le Pare-feu Windows est activé ####

"`nVérification du Pare-feu Windows :" | Out-File -FilePath $chemin -Append
$firewallStatus = (Get-NetFirewallProfile -PolicyStore Local).Enabled
if ($firewallStatus -contains $false) {
    ">>>>>>>>>>>>>> Attention: Le Pare-feu Windows est désactivé." | Out-File -FilePath $chemin -Append
} else {
    ">>>>>>>>>>>>>> Le Pare-feu Windows est activé." | Out-File -FilePath $chemin -Append
}

 $progressBar.Value = 1


##### Vérifier si windows defender est activé ######

$defender = Get-CimInstance -Namespace "root\SecurityCenter2" -ClassName "AntiVirusProduct" | Where-Object { $_.displayName -eq "Windows Defender" }

if ($defender) {
Write-Log ">>>>>>>>>>>>>> Windows Defender est activé et à jour." | Out-File -FilePath $chemin -Append
} 

else {
Write-Log ">>>>>>>>>>>>>> Attention: Windows Defender n'est pas activé ou pas à jour." | Out-File -FilePath $chemin -Append
}

$progressBar.Value = 2

##### Vérifier si les mises à jour automatiques sont activées ####

"`nVérification des mises à jour automatiques :" | Out-File -FilePath $chemin -Append
$autoUpdateStatus = (Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU").AUOptions
if ($autoUpdateStatus -eq 4) {
    "Les mises à jour automatiques sont activées." | Out-File -FilePath $chemin -Append
} else {
    ">>>>>>>>>>>>>> Attention: Les mises à jour automatiques ne sont pas activées." | Out-File -FilePath $chemin -Append
}

$progressBar.Value = 3

# Définir le chemin du fichier journal
$chemin = "$env:USERPROFILE\VERIF_SYSTEME.txt"

# Fonction pour écrire les messages dans le fichier journal
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $Message | Out-File -FilePath $chemin -Append
    Write-Host $Message
}

# Vérification si il y a des mises à jour de sécurité en attente dans Windows Update
Write-Log ">>>>>>>>>>>>>> Vérification si il y a des mises à jour de sécurité en attente dans Windows Update :"
$Session = New-Object -ComObject "Microsoft.Update.Session"
$Searcher = $Session.CreateUpdateSearcher()
$Criteria = "IsInstalled=0 and Type='Software' and IsHidden=0 and CategoryIDs contains 'e6cf1350-c01b-414d-a61f-263d14d133b4'"
$SearchResult = $Searcher.Search($Criteria).Updates

if ($SearchResult.Count -gt 0) {
    foreach ($Update in $SearchResult) {
        Write-Log "Mise à jour en attente : $($Update.Title)"
    }
} else {">>>>>>>>>>>>>> Aucune mise à jour de sécurité en attente." | Out-File -FilePath $chemin -Append
}

$progressBar.Value = 4

##### Vérification des comptes d'administrateur ######
$adminAccounts = Get-LocalUser | Where-Object { $_.Enabled -eq $true -and $_.SID -like "S-1-5-21-*-500" }

if ($adminAccounts) {
    Write-host "Attention: Les comptes d'administrateur suivants sont activés :"
    $adminAccounts | ForEach-Object { Write-host "Compte: $($_.Name)" }
$adminAccounts | ForEach-Object { "Compte: $($_.Name)" | Out-File -FilePath $chemin -Append }

} else {
    ">>>>>>>>>>>>>> Aucun compte d'administrateur n'est activé." | Out-File -FilePath $chemin -Append
}

$progressBar.Value = 5

# Vérification des connexions suspectes sur votre PC
Write-Log "`nVérification des connexions suspectes sur votre PC :"
$portsSuspects = @(4444, 31337, 445, 25, 1433, 3389, 139, 135, 137, 53, 6666, 6669, 7000, 80)
$connexions = Get-NetTCPConnection | Where-Object { $_.State -eq "Established" }
foreach ($connexion in $connexions) {
    $portLocal = $connexion.LocalPort
    $portDistant = $connexion.RemotePort
    if ($portsSuspects -contains $portLocal -or $portsSuspects -contains $portDistant) {
        Write-Log "Connexion suspecte détectée :" -ForegroundColor Red
        Write-Log "Local: $($connexion.LocalAddress):$portLocal"
        Write-Log "Distant: $($connexion.RemoteAddress):$portDistant"
        Write-Log "VERIFIEZ SI CES PORTS OUVERTS SONT LEGITIMES ET UTILES AVEC LA COMMANDE: #Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' }"
    }
}

$progressBar.Value = 6

# Vérification des ports spécifiques
Write-Log "`nVérification des ports spécifiques :"
$ports = @{
    25 = "Port 25 (SMTP) : Utilisé pour envoyer des courriers électroniques non sollicités (spam) et propager des malwares via des pièces jointes malveillantes."
    1433 = "Port 1433 (MS-SQL) : Ciblé lors d'attaques visant les bases de données Microsoft SQL Server."
    3389 = "Port 3389 (RDP) : Utilisé pour l'accès à distance au bureau (Remote Desktop Protocol) ; souvent visé par des attaques de force brute et d'exploitation."
    139 = "Ports 139 (NetBIOS) et 445 (SMB) : Utilisés pour le partage de fichiers Windows (Server Message Block) ; souvent ciblés par des attaques de type ransomware et pour propager des vers tels que WannaCry."
    135 = "Ports 135, 137-139 (RPC) : Utilisés pour le protocole RPC (Remote Procedure Call) et NetBIOS ; souvent visés pour des attaques de type déni de service ou pour exploiter des vulnérabilités dans Windows."
    53 = "Port 53 (DNS) : Utilisé par le service DNS ; peut être utilisé pour un trafic malveillant de type tunneling ou rediriger le trafic vers des serveurs DNS malveillants."
    6666 = "Ports 6666-6669, 7000 (IRC) : Utilisés par les serveurs IRC (Internet Relay Chat) ; peuvent être utilisés par des malwares pour établir des connexions de commande et de contrôle."
    80 = "Ports 80 (HTTP) et 443 (HTTPS) : Utilisés pour le trafic Web normal, mais également utilisés par des malwares pour communiquer avec des serveurs de commande et de contrôle via des protocoles de communication personnalisés."
    4444 = "Ce port est associé à des activités malveillantes telles que l'utilisation par certains malwares pour établir des connexions de commande et de contrôle avec des systèmes compromis. Il peut également être utilisé pour établir des connexions inverses (reverse shells) permettant à des attaquants de prendre le contrôle à distance d'un système. Certains exploits ciblent spécifiquement le port 4444 pour exploiter des vulnérabilités connues dans des applications ou des services."
    31337 = "Ce port est souvent associé aux activités de hacking et à la culture underground de l'informatique. Comme d'autres ports, le port 31337 peut être exploité pour cibler des vulnérabilités connues et mener des attaques contre des systèmes cibles. Son utilisation est souvent liée à des activités illicites et à des tentatives d'intrusion dans des systèmes."
}

foreach ($port in $ports.Keys) {
    if (Test-NetConnection -ComputerName localhost -Port $port -InformationLevel Quiet) {
        $message = $ports[$port]
        Write-Log ">>>>>>>>>>>>>> Port ouvert : $port - $message"
    }
}

Get-NetTCPConnection | Where-Object { $_.State -eq 'Established' } | Out-File -FilePath $chemin -Append

$progressBar.Value = 7

##### Vérification des dossiers partagés #####

$sharedFolders = Get-SmbShare | Where-Object -Property Name -ne 'IPC$'

if ($sharedFolders) {
    Write-Log ">>>>>>>>>>>>>> Attention: Les dossiers partagés suivants ont été trouvés :"
    $sharedFolders | ForEach-Object { Write-Log ">>>>>>>>>>>>>> Dossier: $($_.Name)" }
    $sharedFolders | ForEach-Object { "Dossier: $($_.Name)" | Out-File -FilePath $chemin -Append }

} else {

    ">>>>>>>>>>>>>> Aucun dossier partagé n'a été trouvé." | Out-File -FilePath $chemin -Append
}


$progressBar.Value = 8

# Définir le chemin du fichier journal
$chemin = "$env:USERPROFILE\VERIF_SYSTEME.txt"

# Fonction pour écrire les messages dans le fichier journal
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $Message | Out-File -FilePath $chemin -Append
    Write-Host $Message
}

# Vérification de l'activation de l'UAC
Write-Log "`nVérification de l'activation de l'UAC :" -ForegroundColor Yellow
$UACStatus = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System").EnableLUA
if ($UACStatus -eq 0) {
    Write-Log ">>>>>>>>>>>>>> Attention: UAC (User Account Control) est désactivé."
    $message = ">>>>>>>>>>>>>> Pour activer l'UAC, veuillez ouvrir le Panneau de configuration, cliquer sur 'Comptes d'utilisateurs', puis cliquer sur 'Modifier les paramètres de contrôle de compte d'utilisateur' et déplacer le curseur vers le haut."
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup($message, 0, ">>>>>>>>>>>>>> UAC désactivé", 0x1)
} else {
    Write-Log ">>>>>>>>>>>>>> UAC (User Account Control) est activé."
}

$progressBar.Value = 9

# Vérification de l'activation de BitLocker
Write-Log "`nVérification de l'activation de BitLocker :"
$BitLockerStatus = Get-BitLockerVolume -MountPoint C:
if ($BitLockerStatus.ProtectionStatus -ne "On") {
    Write-Log ">>>>>>>>>>>>>> Attention: BitLocker n'est pas activé sur le disque système. VEUILLEZ L'ACTIVER POUR DES RAISONS DE SECURITE.-----------------"
} else {
    Write-Log ">>>>>>>>>>>>>> BitLocker est activé sur le disque système."
}

$progressBar.Value = 10

# Vérification du service
$serviceName = "Telnet, LPD Service, RemoteRegistry"
Write-Log "`nVérification du service $serviceName :"
try {
    $serviceStatus = Get-Service | Where-Object { $_.Name -eq $serviceName -and $_.Status -eq "Running" }
    if ($serviceStatus) {
        Write-Log ">>>>>>>>>>>>>> Attention: Le service $serviceName est en cours d'exécution."
    } else {
        Write-Log ">>>>>>>>>>>>>> Le service $serviceName n'est pas en cours d'exécution."
    }
}
catch {
    Write-Log ">>>>>>>>>>>>>> Erreur lors de l'interrogation du service $serviceName."
    Write-Log ">>>>>>>>>>>>>> Détails de l'erreur : $_"
}

$progressBar.Value = 11

# Vérification des tâches planifiées
Write-Log "`nVérification des tâches planifiées :"
$scheduledTasks = Get-ScheduledTask
$suspiciousFolders = @("%AppData%", "%Temp%", "C:\Users\Public")
$foundSuspectTask = $false

$scheduledTasks | ForEach-Object {
    $taskName = $_.TaskName
    $taskActions = $_.Actions

    $taskActions | ForEach-Object {
        if ($_.Id -eq 'Execute') {
            foreach ($folder in $suspiciousFolders) {
                if ($_.Execute -like "*$folder*") {
                    Write-Log ">>>>>>>>>>>>>> Tâche suspecte : $taskName"
                    Write-Log ">>>>>>>>>>>>>> Chemin suspect : $($_.Execute)"
                    $foundSuspectTask = $true
                }
            }
        }
    }

    $taskTriggers = $_ | Get-ScheduledTask | Select-Object -ExpandProperty Triggers

    foreach ($trigger in $taskTriggers) {
        if ($trigger.Repetition.Duration -eq 'PT1M') {
            Write-Log "Tâche suspecte : $taskName"
            Write-Log "Fréquence suspecte : Toutes les minutes"
            $foundSuspectTask = $true
        }
    }
}

if (!$foundSuspectTask) {
    Write-Log ">>>>>>>>>>>>>> Aucune tâche suspecte trouvée."
}

$progressBar.Value = 12

##### Mise à jour de la base de données virales####
    update-mpsignature

# Définir le chemin du fichier journal
$chemin = "$env:USERPROFILE\VERIF_SYSTEME.txt"

# Fonction pour écrire les messages dans le fichier journal
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $Message | Out-File -FilePath $chemin -Append
    Write-Host $Message
}

$progressBar.Value = 13

# Vérification si le réseau utilise une mise à jour WSUS non SSL
"Vérification si le réseau utilise une mise à jour WSUS non SSL :"| Out-File -FilePath $chemin -Append

try {
    $verif = Get-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' -Name 'WUServer'
    if ($verif.WUServer -match 'http://') {
        ">>>>>>>>>>>>>> Mises à jour WSUS configurées pour utiliser HTTP, vulnérable aux attaques man-in-the-middle." | Out-File -FilePath $chemin -Append
    } else {
        ">>>>>>>>>>>>>> Mises à jour WSUS configurées pour utiliser HTTPS, plus sécurisé si la clé existe. Mais elle n'existe pas. Aucune connexion à un serveur WSUS n'est configurée sur l'appareil." | Out-File -FilePath $chemin -Append
    }
} catch {
   "<<<<<<<<<<<<<<Cette clé de registre n'existe pas, ou il n'y a pas de mise à jour WSUS configurée>>>>>>>>>>>>>" | Out-File -FilePath $chemin -Append
}

$progressBar.Value = 14

# Vérification de si l'option AlwaysInstallElevated est activée

"Vérification si l'option 'AlwaysInstallElevated' est activée :" | Out-File -FilePath $chemin -Append
try {
    $verifHKCU = Get-ItemProperty -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer' -Name 'AlwaysInstallElevated'
    $verifHKLM = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer' -Name 'AlwaysInstallElevated'
    if ($verifHKCU -and $verifHKLM) {
        ">>>>>>>>>>>>>> Attention : L'option 'AlwaysInstallElevated' est activée dans HKCU et HKLM, cela peut être une vulnérabilité de sécurité." | Out-File -FilePath $chemin -Append
    } else {
        "'>>>>>>>>>>>>>> AlwaysInstallElevated' est désactivé ou partiellement activé, ce qui est plus sûr." | Out-File -FilePath $chemin -Append
    }
} catch {
   ">>>>>>>>>>>>>> Impossible de trouver la clé de registre ou la valeur spécifiée, 'AlwaysInstallElevated' est probablement désactivé." | Out-File -FilePath $chemin -Append
}

$progressBar.Value = 15

# Vérifications des autorisations de lecture/écriture pour tous les chemins et tous les utilisateurs en local
Write-Log "Vérifications des autorisations de lecture/écriture pour tous les chemins et tous les utilisateurs en local"
$paths = $env:path -split ';'
foreach ($path in $paths) {
    try {
        $acl = Get-Acl -Path $path -ErrorAction Stop
        foreach ($access in $acl.Access) {
            if ($access.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::Modify -and
                ($access.IdentityReference.Value -eq 'Everyone' -or
                 $access.IdentityReference.Value -eq 'NT AUTHORITY\Authenticated Users' -or
                 $access.IdentityReference.Value -eq 'Todos' -or
                 $access.IdentityReference.Value -eq "$env:USERDOMAIN\$env:USERNAME")) {
                if ($access.IdentityReference.Value -eq '2AB4B02F-7385-4\WDAGUtilityAccount') {
                    Write-Log ">>>>>>>>>>>>>> $path a des permissions de modification pour $($access.IdentityReference.Value). C'est normal, car ce compte est utilisé par Windows Defender Application Guard." | Out-File -FilePath $chemin -Append

                } else {
                    Write-Log ">>>>>>>>>>>>>> $path a des permissions de modification pour $($access.IdentityReference.Value)" | Out-File -FilePath $chemin -Append

                    Write-Warning ">>>>>>>>> Attention : Cela peut être dangereux, car cela signifie que $($access.IdentityReference.Value) peut modifier les fichiers dans ce chemin." | Out-File -FilePath $chemin -Append

                }
            }
        }
    } catch {
        Write-Log ">>>>>>>>> Impossible d'obtenir les permissions pour $path"
    }
}

$progressBar.Value = 16

# Définir le chemin du fichier journal
$chemin = "$env:USERPROFILE\VERIF_SYSTEME.txt"

# Vérification de la vulnérabilité CVE-2019-1388
"Vérification de la vulnérabilité CVE-2019-1388 :" | Out-File -FilePath $chemin -Append

# Récupérer les informations du système
$osInfo = Get-WmiObject -Class Win32_OperatingSystem

# Extraire le numéro de version et le numéro de build
$version = $osInfo.Version
$build = $osInfo.BuildNumber

# Liste des versions vulnérables
$vulnerableVersions = @(
    @{Version="6.1"; Build="7601"}, # Windows 7 SP1 / Windows 2008r2
    @{Version="6.2"; Build="9200"}, # Windows 8
    @{Version="6.3"; Build="9600"}, # Windows 8.1 / Windows 2012r2
    @{Version="10.0"; Build="10240"}, # Windows 10 1511
    @{Version="10.0"; Build="14393"}  # Windows 10 1607 / Windows 2016
)

# Vérifier si le système est vulnérable
$isVulnerable = $false
foreach ($vulnerableVersion in $vulnerableVersions) {
    if ($version -eq $vulnerableVersion.Version -and $build -eq $vulnerableVersion.Build) {
        $isVulnerable = $true
        break
    }
}

if ($isVulnerable) {
    ">>>>>>>>>>>>>>> Ce système est potentiellement vulnérable à la faille CVE-2019-1388." | Out-File -FilePath $chemin -Append

} else {
    ">>>>>>>>>>>>>>> Ce système ne semble pas être vulnérable à la faille CVE-2019-1388." | Out-File -FilePath $chemin -Append
}

$progressBar.Value = 17

# Vérifier si le secureboot est activé
$secureboot = Confirm-SecureBootUEFI

if ($secureboot -eq $true) {
    ">>>>>>>>>>>>>>>>>>> Le démarrage sécurisé de l'ordinateur est activé." | Out-File -FilePath $chemin -Append
} else {
    ">>>>>>>>>>>>>>>>>> Le démarrage sécurisé de l'ordinateur est désactivé." | Out-File -FilePath $chemin -Append
}

# Exécuter le fichier journal
Start-Process $chemin

$form.close()
        	
	break
#----------------------------------------------------------------------------

})

# Ajouter les contrôles au formulaire
$form.Controls.Add($startButton)

#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Définir le chemin du fichier journal
$chemin = "$env:USERPROFILE\VERIF_SYSTEME.txt"

# Affichage du formulaire "Windows Defender Extension"
$form.ShowDialog()

#----------------------------------------------------------------------------------------------------------------------
Add-Type -AssemblyName System.Windows.Forms

# Création du formulaire principal
$form = New-Object System.Windows.Forms.Form
$form.Text = "Sécurité du système, que souhaitez-vous réparer?"
$form.Size = New-Object System.Drawing.Size(750,500) # J'ai légèrement augmenté la largeur pour s'adapter aux boutons
$form.StartPosition = 'CenterScreen'

###### Ouvrir les options du pare feu ######

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

$form.ShowDialog()


