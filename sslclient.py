# Simple non-context SSL client
import socket,ssl
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sslsock = ssl.wrap_socket(s,
    keyfile="./dev.ghazan.work.key.pem",
    certfile="./dev.cert.pem",
    ca_certs="./ca-chain.cert.pem",
    cert_reqs=ssl.CERT_REQUIRED,
    ssl_version=ssl.PROTOCOL_TLSv1)
sslsock.connect(('dev.ghazan.work',8011))
sslsock.send('i am client')
data = sslsock.recv(1024)
sslsock.close()
print "Received: " + data
