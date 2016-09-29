# Simple non-context SSL server
import socket,ssl
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sslsock = ssl.wrap_socket(s,
    keyfile="./dev.ghazan.work.key.pem",
    certfile="./dev.cert.pem",
    ca_certs="./ca-chain.cert.pem",
    server_side=True,
    cert_reqs=ssl.CERT_REQUIRED,
    ssl_version=ssl.PROTOCOL_TLSv1)
sslsock.bind(('',8011))
sslsock.listen(5)
conn,addr = sslsock.accept()
data = conn.recv(1024)
conn.send('i am server')
conn.close()
print "Received: " + data
