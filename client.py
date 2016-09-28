import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#s.bind(('',8011))
#s.listen(5)
s.connect(('127.0.0.1',8011))
s.send('i am client')
data = s.recv(1024)
s.close()
print "Received: " + data
