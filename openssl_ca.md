Creating a local CA and self-signed certs
=========================================

Create a local CA using OpenSSL:

```
mkdir /root/ca
cd /root/ca
mkdir certs crl newcerts private
chmod 700 private/
touch index.txt
echo 1000 > serial
vi openssl.cnf     # Add root CA config file here
openssl genrsa -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem 
openssl req -config openssl.cnf -key private/ca.key.pem -new -x509 -days 7300 -sha256 -extensions v3_ca -out certs/ca.cert.pem
chmod 444 certs/ca.cert.pem 
openssl x509 -noout -text -in certs/ca.cert.pem # Checking
```

Now create the Intermediate CA:

```
mkdir /root/ca/intermediate
cd /root/ca/intermediate
mkdir certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber
vi openssl.cnf     # Add Intermediate CA config file here
cd ..
openssl genrsa -aes256       -out intermediate/private/intermediate.key.pem 4096
chmod 400 intermediate/private/intermediate.key.pem
openssl req -config intermediate/openssl.cnf -new -sha256 -key intermediate/private/intermediate.key.pem -out intermediate/csr/intermediate.csr.pem
openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in intermediate/csr/intermediate.csr.pem -out intermediate/certs/intermediate.cert.pem
chmod 444 intermediate/certs/intermediate.cert.pem
```

Check the result:

```
cat index.txt
cat intermediate/index.txt 
openssl x509 -noout -text -in intermediate/certs/intermediate.cert.pem
openssl verify -CAfile certs/ca.cert.pem intermediate/certs/intermediate.cert.pem
```

Produce a CA chain:

```
cat intermediate/certs/intermediate.cert.pem certs/ca.cert.pem > ca-chain.cert.pem
chmod 444 ca-chain.cert.pem 
```


CA is up. Now for the CSR and certificate
-----------------------------------------

Private key and CSR:
```
openssl genrsa -out intermediate/private/dev.ghazan.work.key.pem 2048
chmod 400 intermediate/private/dev.ghazan.work.key.pem 
openssl req -config intermediate/openssl.cnf -key intermediate/private/dev.ghazan.work.key.pem -new -sha256 -out intermediate/private/dev.ghazan.work.csr.pem
openssl ca -config intermediate/openssl.cnf -extensions server_cert -days 6000 -notext -md sha256 -in intermediate/private/dev.ghazan.work.csr.pem -out intermediate/private/dev.ghazan.work.cert.pem
chmod 444 intermediate/private/dev.ghazan.work.cert.pem 
```

Check and confirm:

```
cat intermediate/index.txt
openssl x509 -noout -text -in intermediate/private/dev.ghazan.work.cert.pem 
openssl verify -CAfile ca-chain.cert.pem intermediate/private/dev.ghazan.work.cert.pem
```


Copy the files for use:

```
cp ca-chain.cert.pem ..
cp intermediate/private/dev.ghazan.work.key.pem ..
cp intermediate/private/dev.ghazan.work.cert.pem ..
```
