import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(('',8011))
s.listen(5)
conn,addr = s.accept()
data = conn.recv(1024)
conn.send('i am server')
conn.close()
print "Received: " + data
