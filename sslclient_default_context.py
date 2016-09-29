# Using ssl.create_default_context does something that fails
# our connections looking for CA file. It only works if we
# remove Purpose.SERVER_AUTH and add load_verify_locations:

import socket,ssl
context = ssl.create_default_context()#ssl.Purpose.SERVER_AUTH )
context.load_cert_chain(certfile="./cert.pem")
context.load_verify_locations("./cert.pem")
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sslsock = context.wrap_socket(s,server_hostname="127.0.0.1")
sslsock.connect(('127.0.0.1',8011))
sslsock.send('i am client')
data = sslsock.recv(1024)
sslsock.close()
print "Received: " + data
