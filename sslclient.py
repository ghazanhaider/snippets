import socket,ssl
context = ssl.SSLContext(ssl.PROTOCOL_TLSv1)
context.load_cert_chain(certfile="./cert.pem")
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sslsock = context.wrap_socket(s)
sslsock.connect(('127.0.0.1',8011))
sslsock.send('i am client')
data = sslsock.recv(1024)
sslsock.close()
print "Received: " + data
