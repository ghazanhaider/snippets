Snippets
========

Basic snippets:

* server.py and client.py are basic sockets client and server (fixed message size of 1024)
* sslserver.py and sslclient.py are basic SSL sockets, fixed message size, ssl client and server auth. Separate certificates will have to be created when these apps run on different hosts.
* The default_context pair use ssl.create_default_context but have specific requirements to make them work.


How to confirm SSL:
`openssl s_client -showcerts -connect 127.0.0.1:8011`

How to generate test certs:

`openssl req -new -x509 -days 365 -nodes -out cert.pem -keyout key.pem`

Client testing:

`openssl s_client -showcerts -connect 127.0.0.1:8011 -ssl3`

Server testing:

`openssl s_server -accept 8011 -cert cert.pem`

Server www testing:

`openssl s_server -cert ./cert.pem -www`

Much more detailed client side testing:

`openssl s_client -connect dev.ghazan.work:8011 -cert ./dev.cert.pem -key ./dev.ghazan.work.key.pem  -CAfile ./ca-chain.cert.pem -state  -debug -tls1 -servername dev.ghazan.work -verify 10`
