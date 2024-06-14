import sys
from time import sleep
import paramiko

router="10.46.0.2"
  
# Create an ssh connection and set terminal length 0
conn = paramiko.SSHClient()
conn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
conn.connect(router, username="tester", password="foobar")
router_conn = conn.invoke_shell()
print('Successfully connected to %s' % router)
router_conn.send('terminal length 0\n')
sleep(1)        # Wait for the cmd to be sent and processed  
# Send the command and wait for it to execute
router_conn.send("show arp\n")
sleep(2)
  
# Read the output, decode into UTF-8 (ASCII) text, and print
print(router_conn.recv(5000).decode("utf-8"))