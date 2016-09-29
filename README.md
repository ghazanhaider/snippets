Snippets
========

Basic snippets:

* server.py and client.py are basic sockets client and server (fixed message size of 1024)
* sslserver.py and sslclient.py are basic SSL sockets, fixed message size (no host validation)
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
