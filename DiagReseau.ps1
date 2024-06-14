# Charger les assemblages nécessaires
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Créer la fenêtre principale
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Outil de Diagnostic Réseau'
$form.Size = New-Object System.Drawing.Size(900,600)
$form.StartPosition = 'CenterScreen'

# Ajouter une zone de texte pour l'adresse IP et les ports
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,10)
$textBox.Size = New-Object System.Drawing.Size(300,200)
$form.Controls.Add($textBox)

# Fonction pour créer un bouton
function New-Button($text, $size, $location, $action) {
    $button = New-Object System.Windows.Forms.Button
    $button.Size = $size
    $button.Location = $location
    $button.Text = $text
    $button.Add_Click($action)
    $form.Controls.Add($button)
    return $button
}

# Créer les boutons pour chaque fonctionnalité
$buttonSize = New-Object System.Drawing.Size(180,50)
$y = 40
$buttons = @(
    @{Text='Ping'; Action={
        $outputBox.Clear()
        try {
            $result = Test-Connection -ComputerName $textBox.Text -Count 4
            $outputBox.AppendText(($result | Out-String))
        } catch {
            $outputBox.AppendText("Erreur lors du ping : " + $_.Exception.Message)
        }
    }},
    @{Text='Traceroute'; Action={
        $outputBox.Clear()
        try {
            # Exécuter tracert et capturer la sortie
            $result = & tracert $textBox.Text
            # Afficher la sortie dans le $outputBox
            $outputBox.AppendText(($result | Out-String))
        } catch {
            # En cas d'erreur, afficher le message d'erreur
            $outputBox.AppendText("Erreur lors du traceroute : " + $_.Exception.Message)
        }
    }}

,
@{Text='Analyser les Ports'; Action={
    $outputBox.Clear()
    # Liste des ports courants à tester
    $portsToTest = @(21, 22, 23, 25, 53, 80, 110, 143, 443, 465, 587, 993, 995, 3306, 8080)

    $computerName = $textBox.Text

    # Assurez-vous que l'utilisateur a saisi une adresse IP ou un nom de domaine
    if (![string]::IsNullOrWhiteSpace($computerName)) {
        $outputBox.AppendText("Analyse des ports sur $computerName...`n")
        foreach ($port in $portsToTest) {
            try {
                $result = Test-NetConnection -ComputerName $computerName -Port $port -InformationLevel Quiet
                if ($result) {
                    $outputBox.AppendText("Port $port est ouvert.`n")
                } else {
                    $outputBox.AppendText("Port $port est fermé ou filtré.`n")
                }
            } catch {
                $outputBox.AppendText("Erreur lors de la vérification du port $port : " + $_.Exception.Message + "`n")
            }
        }
    } else {
        $outputBox.AppendText("Veuillez entrer une adresse IP ou un nom de domaine.`n")
    }
}}


,
@{Text='Surveillance Bande Passante'; Action={
    $outputBox.Clear()
    $outputBox.AppendText("Surveillance de la bande passante en cours...`n")

    # Obtenir les informations de l'interface réseau
    $networkAdapters = Get-WmiObject Win32_NetworkAdapter -Filter "NetEnabled = true"

    if ($networkAdapters) {
        # Sélectionner la première interface active
        $adapter = $networkAdapters[0]

        # Obtenir les statistiques initiales de l'interface
        $initialStats = Get-WmiObject Win32_PerfFormattedData_Tcpip_NetworkInterface | Where-Object { $_.Name -eq $adapter.Name }

        # Attendre un intervalle de temps (ex. 1 seconde)
        Start-Sleep -Seconds 1

        # Obtenir les statistiques mises à jour de l'interface
        $updatedStats = Get-WmiObject Win32_PerfFormattedData_Tcpip_NetworkInterface | Where-Object { $_.Name -eq $adapter.Name }

        # Calculer la bande passante utilisée
        $bytesReceivedPerSec = $updatedStats.BytesReceivedPerSec - $initialStats.BytesReceivedPerSec
        $bytesSentPerSec = $updatedStats.BytesSentPerSec - $initialStats.BytesSentPerSec

        $outputBox.AppendText("Vitesse de réception : $bytesReceivedPerSec Bytes/s`n")
        $outputBox.AppendText("Vitesse d'envoi : $bytesSentPerSec Bytes/s`n")
    } else {
        $outputBox.AppendText("Aucune interface réseau active trouvée.`n")
    }
}}

,
@{Text='Infos Réseau'; Action={
    $outputBox.Clear()
    try {
        # Obtenir les configurations de l'adaptateur réseau actif
        $networkConfigurations = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }

        foreach ($config in $networkConfigurations) {
            $outputBox.AppendText("Description: " + $config.Description + "`n`n")
            $outputBox.AppendText("Adresse IP: " + ($config.IPAddress -join ', ') + "`n`n")
            $outputBox.AppendText("Masque de sous-réseau: " + ($config.IPSubnet -join ', ') + "`n`n")
            $outputBox.AppendText("Passerelle par défaut: " + ($config.DefaultIPGateway -join ', ') + "`n`n")
            $outputBox.AppendText("Serveurs DNS: " + ($config.DNSServerSearchOrder -join ', ') + "`n`n")
            $outputBox.AppendText("------------------------------------------------`n`n")
        }
    } catch {
        $outputBox.AppendText("Erreur lors de l'affichage des informations réseau: " + $_.Exception.Message + "`n`n")
    }
}}



@{Text='Cartographie Réseau'; Action={
    $outputBox.Clear()
    $outputBox.AppendText("Démarrage de la cartographie du réseau...`n")

    # Spécifiez la plage d'adresses IP à tester
    $startIP = "192.168.1.1"
    $endIP = "192.168.1.254"
    
    # Convertir les adresses IP en entiers pour la boucle
    $startAddr = [System.Net.IPAddress]::Parse($startIP).GetAddressBytes()
    [Array]::Reverse($startAddr)
    $startInt = [System.BitConverter]::ToUInt32($startAddr, 0)
    
    $endAddr = [System.Net.IPAddress]::Parse($endIP).GetAddressBytes()
    [Array]::Reverse($endAddr)
    $endInt = [System.BitConverter]::ToUInt32($endAddr, 0)
    
    for ($i = $startInt; $i -le $endInt; $i++) {
        $addrBytes = [System.BitConverter]::GetBytes($i)
        [Array]::Reverse($addrBytes)
        $ip = [System.Net.IPAddress]::new($addrBytes)
        
        if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
            try {
                $hostName = Resolve-DnsName -Name $ip -ErrorAction Stop | Select-Object -ExpandProperty NameHost
                $outputBox.AppendText("Dispositif trouvé à l'adresse : $ip (`$hostName : $hostName`n)")
            } catch {
                $outputBox.AppendText("Dispositif trouvé à l'adresse : $ip (Nom d'hôte non résolu)`n")
            }
        }
    }

    $outputBox.AppendText("Cartographie du réseau terminée.`n")
}}

,@{Text='État du Réseau'; Action={
    $outputBox.Clear()
    $outputBox.AppendText("Vérification de l'état du réseau...`n")

    # Liste des serveurs ou des services à tester
   $serversToTest = @(
    "www.google.com",    # Serveur Web Google - Teste la connectivité Internet générale
    "www.microsoft.com", # Serveur Web Microsoft - Teste la connectivité Internet générale
    "8.8.8.8",           # Serveur DNS Google - Teste la résolution DNS
    "1.1.1.1",           # Serveur DNS Cloudflare - Teste la résolution DNS
    "www.amazon.com",    # Serveur Web Amazon - Teste la connectivité Internet générale
    "www.facebook.com",  # Serveur Web Facebook - Teste la connectivité Internet générale
    "www.yahoo.com",     # Serveur Web Yahoo - Teste la connectivité Internet générale
    "www.bing.com",      # Serveur Web Bing - Teste la connectivité Internet générale
    "yourcompany.com",   # Serveur Web interne ou site de votre entreprise
    "mail.yourcompany.com" # Serveur de messagerie interne
    # Vous pouvez ajouter ici d'autres serveurs spécifiques à votre réseau ou organisation
)


    foreach ($server in $serversToTest) {
        try {
            $pingResult = Test-Connection -ComputerName $server -Count 1 -Quiet
            if ($pingResult) {
                $outputBox.AppendText(">>>>>>>>$server est accessible.`n")
            } else {
                $outputBox.AppendText(">>>>>>>>$server n'est pas accessible.`n")
            }
        } catch {
            $outputBox.AppendText(">>>>>>>>Erreur lors de la tentative de connexion à $server : " + $_.Exception.Message + "`n")
        }
    }

    $outputBox.AppendText("-----------VERIFICATION DE L'ETAT DU RESEAU TERMINE.`n-----------")
}}
,



@{Text='Rapports'; Action={
    $outputBox.Clear()
    $outputBox.AppendText("Génération du rapport de réseau...`n")

    try {
        # Rapport sur les configurations IP des adaptateurs réseau
        $networkConfigurations = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }
        foreach ($config in $networkConfigurations) {
            $outputBox.AppendText("Adaptateur: " + $config.Description + "`n")
            $outputBox.AppendText("Adresse IP: " + ($config.IPAddress -join ', ') + "`n")
            $outputBox.AppendText("Masque de sous-réseau: " + ($config.IPSubnet -join ', ') + "`n")
            $outputBox.AppendText("Passerelle par défaut: " + ($config.DefaultIPGateway -join ', ') + "`n")
            $outputBox.AppendText("Serveurs DNS: " + ($config.DNSServerSearchOrder -join ', ') + "`n`n")
        }

        # Statistiques de performance réseau
        $outputBox.AppendText("Statistiques de performance réseau :`n")
        $networkStats = Get-NetAdapterStatistics -Verbose
        foreach ($stat in $networkStats) {
            $outputBox.AppendText("Adaptateur: " + $stat.Name + "`n")
            $outputBox.AppendText("Bytes envoyés: " + $stat.BytesSent + "`n")
            $outputBox.AppendText("Bytes reçus: " + $stat.BytesReceived + "`n`n")
        }

        # Vérification de la connectivité de certains serveurs
        $servers = @("www.google.com", "www.microsoft.com")
        foreach ($server in $servers) {
            $pingResult = Test-Connection -ComputerName $server -Count 1 -Quiet
            $status = if ($pingResult) { "Accessible" } else { "Non accessible" }
            $outputBox.AppendText("Connectivité vers $server : $status`n")
        }

        # Journaux d'événements réseau (exemple simple)
        $outputBox.AppendText("Journaux d'événements réseau récents :`n")
        $eventLogs = Get-EventLog -LogName 'System' -Source 'Tcpip' -Newest 5
        foreach ($log in $eventLogs) {
            $outputBox.AppendText("Événement : " + $log.EntryType + " - " + $log.Message + "`n")
        }

        $outputBox.AppendText("`nRapport de réseau généré avec succès.`n")
    } catch {
        $outputBox.AppendText("Erreur lors de la génération du rapport de réseau: " + $_.Exception.Message)
    }
}}
,

@{Text='Config Réseau'; Action={
    $outputBox.Clear()

    # Utiliser Get-WmiObject pour obtenir les informations de l'adaptateur réseau
    try {
        $adapter = Get-WmiObject -Class Win32_NetworkAdapter -Filter "NetConnectionStatus = 2" | Select-Object -First 1
        if ($adapter) {
            $ipConfig = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "InterfaceIndex = $($adapter.InterfaceIndex)"
            $outputBox.AppendText("Adaptateur actuel: " + $adapter.NetConnectionID + "`n")
            $outputBox.AppendText("Adresse IP actuelle: " + ($ipConfig.IPAddress[0]) + "`n")

            # Demander à l'utilisateur de saisir une nouvelle adresse IP
            $newIPAddress = [Microsoft.VisualBasic.Interaction]::InputBox("Entrez une nouvelle adresse IP pour " + $adapter.NetConnectionID, "Nouvelle Adresse IP", $ipConfig.IPAddress[0])
            $newSubnet = [Microsoft.VisualBasic.Interaction]::InputBox("Entrez le masque de sous-réseau", "Nouveau Masque de Sous-Réseau", $ipConfig.IPSubnet[0])

            if (![string]::IsNullOrWhiteSpace($newIPAddress) -and ![string]::IsNullOrWhiteSpace($newSubnet)) {
                # Définir la nouvelle adresse IP (cette opération peut nécessiter des privilèges d'administrateur)
                $ipConfig.EnableStatic($newIPAddress, $newSubnet)
                $outputBox.AppendText("Adresse IP mise à jour : " + $newIPAddress + "`n")
            }

            # Mettre à jour les paramètres DNS si nécessaire
            # ...

        } else {
            $outputBox.AppendText("Aucun adaptateur réseau actif trouvé.`n")
        }
    } catch {
        $outputBox.AppendText("Erreur lors de la configuration de l'adresse IP: " + $_.Exception.Message)
    }
}}

, @{Text='Tester la sécurité de mon PC'; Action={
    $outputBox.Clear()
    try {
        $securityScriptPath = "C:\Users\Remi\Desktop\VERIF_SECU_SYSTEME.ps1"
        Start-Process powershell -ArgumentList "-Command & {Start-Process powershell -Verb RunAs -ArgumentList '-File ""$securityScriptPath""'}"
        $outputBox.AppendText("Test de sécurité en cours...`n")
    } catch {
        $outputBox.AppendText("Erreur lors de l'exécution du script de sécurité : " + $_.Exception.Message)
    }
}}

)
foreach ($buttonInfo in $buttons) {
    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point(10, $y)
    $button.Size = $buttonSize
    $button.Text = $buttonInfo.Text
    $button.Add_Click($buttonInfo.Action)
    $form.Controls.Add($button)
    $y += 40
}

# Ajouter une zone de texte multiligne pour les résultats
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Multiline = $true
$outputBox.Location = New-Object System.Drawing.Point(300,40)
$outputBox.Size = New-Object System.Drawing.Size(380,420)
$outputBox.ScrollBars = 'Vertical'
$form.Controls.Add($outputBox)

# Ajouter un bouton pour effacer les résultats
$clearButton = New-Button "Effacer les Résultats", (New-Object System.Drawing.Size(180,50), (700,40), {
    $outputBox.Clear()
})

# Ajouter un bouton pour quitter l'application
$exitButton = New-Button "Quitter", (New-Object System.Drawing.Size(180,50), (700,100), {
    $form.Close()
})


# Afficher la fenêtre
$form.ShowDialog()
