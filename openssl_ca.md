Creating a local CA and self-signed certs
=========================================

```
mkdir /root/ca
cd /root/ca
mkdir certs crl newcerts private
chmod 700 private/
touch index.txt
echo 1000 > serial
vi openssl.cnf
openssl genrsa -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem 
openssl req -config openssl.cnf       -key private/ca.key.pem       -new -x509 -days 7300 -sha256 -extensions v3_ca       -out certs/ca.cert.pem
chmod 444 certs/ca.cert.pem 
openssl x509 -noout -text -in certs/ca.cert.pem 
mkdir /root/ca/intermediate
cd /root/ca/intermediate
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber
vi openssl.cnf
cd ..
openssl genrsa -aes256       -out intermediate/private/intermediate.key.pem 4096
chmod 400 intermediate/private/intermediate.key.pem
openssl req -config intermediate/openssl.cnf -new -sha256       -key intermediate/private/intermediate.key.pem       -out intermediate/csr/intermediate.csr.pem
openssl ca -config openssl.cnf -extensions v3_intermediate_ca       -days 3650 -notext -md sha256       -in intermediate/csr/intermediate.csr.pem       -out intermediate/certs/intermediate.cert.pem
chmod 444 intermediate/certs/intermediate.cert.pem
cat index.txt
cat intermediate/index.txt 
openssl x509 -noout -text       -in intermediate/certs/intermediate.cert.pem
openssl verify -CAfile certs/ca.cert.pem       intermediate/certs/intermediate.cert.pem
cat intermediate/certs/intermediate.cert.pem       certs/ca.cert.pem > ca-chain.cert.pem
chmod 444 ca-chain.cert.pem 
openssl genrsa -out intermediate/private/dev.ghazan.work.key.pem 2048
chmod 400 intermediate/private/dev.ghazan.work.key.pem 
echo CSR starts
openssl req -config intermediate/openssl.cnf -key intermediate/private/dev.ghazan.work.key.pem -new -sha256 -out intermediate/private/dev.ghazan.work.csr.pem
openssl ca -config intermediate/openssl.cnf -extensions server_cert -days 6000 -notext -md sha256 -in intermediate/private/dev.ghazan.work.csr.pem -out intermediate/private/dev.ghazan.work.cert.pem
chmod 444 intermediate/private/dev.ghazan.work.cert.pem 
cat intermediate/index.txt
openssl x509 -noout -text -in intermediate/certs/www.example.com.cert.pem
openssl x509 -noout -text -in intermediate/certs/dev.ghazan.work.cert.pem
openssl x509 -noout -text -in intermediate/private/dev.ghazan.work.cert.pem 
openssl verify -CAfile intermediate/certs/ca-chain.cert.pem       intermediate/private/dev.ghazan.work.cert.pem 
openssl verify -CAfile ca-chain.cert.pem       intermediate/private/dev.ghazan.work.cert.pem 
cp ca-chain.cert.pem ..
cp intermediate/private/dev.ghazan.work.key.pem ..
cp intermediate/private/dev.ghazan.work.cert.pem ..
history > ../openssl_ca_howto
```
