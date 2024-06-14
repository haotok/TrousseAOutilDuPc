#import urllib.request

#url = 'https://www.hilton.com.tr/'
#headers = { 'User-Agent' : 'Mozilla/5.0 (Windows NT 6.3; WOW64)' }

#request = urllib.request.Request(url, None, headers)
#response = urllib.request.urlopen(request)
#headers = response.headers

#print(headers)

import tkinter as tk
import urllib.request

import tkinter as tk
import urllib.request

def get_headers():
    url = url_entry.get()
    headers = { 'User-Agent' : 'Mozilla/5.0 (Windows NT 6.3; WOW64)' }
    request = urllib.request.Request(url, None, headers)
    response = urllib.request.urlopen(request)
    headers = response.headers
    return headers

def show_headers():
    headers = get_headers()
    headers_text.delete('1.0', tk.END)
    headers_text.insert(tk.END, str(headers))

root = tk.Tk()
root.title('En-têtes de réponse HTTP')

url_label = tk.Label(root, text='URL:')
url_label.pack()

#url_entry = tk.Entry(root)
#url_entry.pack()

#headers_button = tk.Button(root, text='Afficher les en-têtes', command=show_headers)
#headers_button.pack()

#headers_label = tk.Label(root, text='En-têtes de réponse HTTP:')
#headers_label.pack()

#headers_text = tk.Text(root)
#headers_text.pack()

#root.mainloop()

import tkinter as tk
import urllib.request

def get_headers():
    url = url_entry.get()
    headers = { 'User-Agent' : 'Mozilla/5.0 (Windows NT 6.3; WOW64)' }
    request = urllib.request.Request(url, None, headers)
    response = urllib.request.urlopen(request)
    headers = response.headers
    return headers

def show_headers():
    headers = get_headers()
    headers_text.delete('1.0', tk.END)
    headers_text.insert(tk.END, str(headers))
    
    # Vérification des vulnérabilités
    vulnerabilities = []
    if 'x-frame-options' not in headers:
        vulnerabilities.append('Clickjacking')
    if 'content-security-policy' not in headers:
        vulnerabilities.append('Injection de script')
    if 'strict-transport-security' not in headers:
        vulnerabilities.append('Attaque SSL')
    
    if vulnerabilities:
        vulnerabilities_text.delete('1.0', tk.END)
        vulnerabilities_text.insert(tk.END, 'Potentielles vulnérabilités : \n')
        for vuln in vulnerabilities:
            vulnerabilities_text.insert(tk.END, vuln + '\n')
    else:
        vulnerabilities_text.delete('1.0', tk.END)
        vulnerabilities_text.insert(tk.END, 'Pas de potentielles vulnérabilités.\n')

root = tk.Tk()
root.title('En-têtes de réponse HTTP')

url_label = tk.Label(root, text='URL:')
url_label.pack()

url_entry = tk.Entry(root)
url_entry.pack()

headers_button = tk.Button(root, text='Afficher les en-têtes', command=show_headers)
headers_button.pack()

headers_label = tk.Label(root, text='En-têtes de réponse HTTP:')
headers_label.pack()

headers_text = tk.Text(root)
headers_text.pack()

vulnerabilities_label = tk.Label(root, text='Potentielles vulnérabilités:')
vulnerabilities_label.pack()

vulnerabilities_text = tk.Text(root)
vulnerabilities_text.pack()

root.mainloop()

