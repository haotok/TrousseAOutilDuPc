import socket
import sys

def ipRange(start_ip, end_ip):
   start = list(map(int, start_ip.split(".")))
   end = list(map(int, end_ip.split(".")))
   temp = start
   ip_range = []
   ip_range.append(start_ip)
   while temp != end:
      start[3] += 1
      for i in (3, 2, 1):
         if temp[i] == 256:
            temp[i] = 0
            temp[i-1] += 1
      ip_range.append(".".join(map(str, temp)))    
   return ip_range

ip_range = ipRange("192.168.0.0", "192.168.255.255")
ip_up = []
for ip in ip_range:
    try:
        result = requests.get("https://vimeo.com/"+ip+"/:80",timeout=0.5).content
        if result is not :
            ip_up.append(ip)
            print ("[+] Machine : "+ip)
    except:
        pass

print("\n".join(ip_up))
