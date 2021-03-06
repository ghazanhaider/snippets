# Using ssl.create_default_context

import socket,ssl
context = ssl.create_default_context(ssl.Purpose.SERVER_AUTH )
context.load_cert_chain(certfile="./dev.cert.pem",keyfile="./dev.ghazan.work.key.pem")

context.load_verify_locations(cafile="./ca-chain.cert.pem")
context.verify_mode = ssl.CERT_REQUIRED
context.check_hostname = True
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sslsock = context.wrap_socket(s,server_hostname="dev.ghazan.work")
sslsock.connect(('dev.ghazan.work',8011))
sslsock.send('i am client')
data = sslsock.recv(1024)
sslsock.close()
print "Received: " + data
