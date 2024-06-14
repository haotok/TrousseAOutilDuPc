import tkinter as tk
from tkinter import filedialog
import json
import time
import os

# Fonction qui envoie le fichier à VirusTotal et récupère le rapport d'analyse
def send_file_vt(filepath):
    url = 'https://www.virustotal.com/vtapi/v2/file/scan'
    params = {'apikey': 'b6ee96c64690cff5dbaa3c524c7d2f28446caadd66f019fbcef1b2f012a7bf80'}
    files = {'file': (filepath, open(filepath, 'rb'))}
    response = requests.post(url, files=files, params=params)
    sha256 = response.json()['sha256']
    report_url = 'https://www.virustotal.com/vtapi/v2/file/report'
    while True:
        time.sleep(15) # Attendre 15 secondes avant de récupérer le rapport
        response = requests.get(report_url, params={'apikey': 'INSÉREZ VOTRE CLEF API ICI', 'resource': sha256})
        if response.json()['response_code'] == 1:
            break
    return response.json()

# Fonction qui affiche un message à l'utilisateur
def show_message(message):
    root = tk.Tk()
    root.withdraw()
    tk.messagebox.showinfo(title='Analyse de VirusTotal', message=message)

# Création de l'interface graphique
root = tk.Tk()
root.withdraw()

filepath = filedialog.askopenfilename(title='Sélectionnez un fichier à analyser')

if filepath:
    use_vt = tk.messagebox.askyesno(title='Analyse de VirusTotal', message='Voulez-vous analyser le fichier avec VirusTotal ?')
    if use_vt:
        response_json = send_file_vt(filepath)
        report = response_json['positives']
        if report > 0:
            message = f"Le fichier est infecté ({report} détections positives)."
        else:
            message = "Le fichier n'est pas infecté."
        show_message(message)
    else:
        message = "Le fichier a été analysé sans utiliser VirusTotal."
        show_message(message)
else:
    message = "Veuillez sélectionner un fichier à analyser."
    show_message(message)
