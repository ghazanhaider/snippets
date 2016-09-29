# Simplest SSL connection

import socket,ssl
context = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
context.load_cert_chain(certfile="./cert.pem")
context.verify_mode = ssl.CERT_REQUIRED
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sslsock = context.wrap_socket(s,server_hostname="dev.ghazan.work")
sslsock.connect(('dev.ghazan.work',8011))
sslsock.send('i am client')
data = sslsock.recv(1024)
sslsock.close()
print "Received: " + data
