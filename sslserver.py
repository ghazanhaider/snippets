# Simplest SSL connection

import socket,ssl
context = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
context.load_cert_chain(certfile="./cert.pem")
context.options &= ~ssl.OP_NO_SSLv3
context.verify_mode = ssl.CERT_REQUIRED
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sslsock = context.wrap_socket(s)
sslsock.bind(('',8011))
sslsock.listen(5)
conn,addr = sslsock.accept()
data = conn.recv(1024)
conn.send('i am server')
conn.close()
print "Received: " + data
