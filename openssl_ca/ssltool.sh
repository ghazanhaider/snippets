#!/bin/bash

####################################################################
# A tool to quickly create a CA and generate signed SSL certificates
####################################################################


#   Examples:

# Create CA store and output ca chain file:
# sshtool.sh -A -p <path> -o <orgname> -c <commonname>

# Generate Server SSL cert (think https):
# ssltool.sh -S -p <path_to_ca> -o <orgname> -c <commonname>


#   Modes:
#
# -A = Create CA (including CA private key)
# -S = Server certificate (including private key, csr request,
#                          signed certificate and CA chain for each run)

# -C = Client certificate (same as above)
# -B = Both types of certificate combined, dual use


#   Config:
#

OPENSSL_CONF=/root/snippets/openssl_ca/openssl_root.cnf
OPENSSL_INTER_CONF=/root/snippets/openssl_ca/openssl_inter.cnf

# First line of this file must be a sufficiently 
# complex passphrase for CA and Intr keys:
PASSPHRASE_FILE=/tmp/pass 

ROOT_CA_EXPIRY=7300
DEFAULT_CERT_EXPIRY=6000
DEFAULT_COUNTRY=PK
DEFAULT_STATE=Balochistan
DEFAULT_LOCALITY=Quetta
DEFAULT_ORG=Hajiabad # !!!!!!!!!!!! Need to fix this override with $org


# Main function to create a new CA
#

create_ca_main() {
	cd $ca_path
	mkdir certs crl newcerts private
	chmod 700 private/
	touch index.txt
	echo 1000 > serial
	cat $OPENSSL_CONF | sed "s|CA_DIR_REPLACE|$ca_path|" > $ca_path/openssl.cnf
	echo "Generating CA private key"
	openssl genrsa -aes256 -out private/ca.key.pem -passout file:/tmp/pass 4096
	chmod 400 private/ca.key.pem
	echo "Generating CA cert"
	openssl req \
        -config openssl.cnf \
        -key private/ca.key.pem \
        -new \
        -x509 \
        -days $ROOT_CA_EXPIRY \
        -sha256 -extensions v3_ca \
        -out certs/ca.cert.pem \
        -passin file:/tmp/pass \
        -subj "/C=$DEFAULT_COUNTRY/ST=$DEFAULT_STATE/L=$DEFAULT_LOCALITY/O=$DEFAULT_ORG/CN=$common_name"

	chmod 444 certs/ca.cert.pem

	echo "Generating Intermediate Key"
	mkdir $ca_path/intermediate
	cd $ca_path/intermediate
	mkdir certs crl csr newcerts private
	chmod 700 private
	touch index.txt
	echo 1000 > serial
	echo 1000 > crlnumber
	cat $OPENSSL_INTER_CONF | \
        sed "s|INTER_DIR_REPLACE|$ca_path/intermediate|" > \
        $ca_path/intermediate/openssl.cnf

	cd ..
	openssl genrsa \
        -aes256 \
        -out $ca_path/intermediate/private/intermediate.key.pem \
        -passout file:/tmp/pass 4096 

	chmod 400 $ca_path/intermediate/private/intermediate.key.pem

	echo "Generating Intermediate cert request"
	openssl req \
        -config $ca_path/intermediate/openssl.cnf \
        -new -sha256 \
        -key $ca_path/intermediate/private/intermediate.key.pem \
        -out $ca_path/intermediate/csr/intermediate.csr.pem \
        -passin file:/tmp/pass \
        -subj "/C=$DEFAULT_COUNTRY/ST=$DEFAULT_STATE/L=$DEFAULT_LOCALITY/O=$DEFAULT_ORG/CN=Intermediate"

	echo "Signing Intermediate cert"
	openssl ca \
        -config $ca_path/openssl.cnf \
        -extensions v3_intermediate_ca \
        -days $ROOT_CA_EXPIRY -notext -md sha256 \
        -passin file:/tmp/pass \
        -batch \
        -in $ca_path/intermediate/csr/intermediate.csr.pem \
        -out $ca_path/intermediate/certs/intermediate.cert.pem \
        >> $ca_path/log.txt 2>&1

	chmod 444 $ca_path/intermediate/certs/intermediate.cert.pem
    echo "The certificate chain including CA and intermediate:"
    cat $ca_path/intermediate/certs/intermediate.cert.pem \
        $ca_path/certs/ca.cert.pem > $ca_path/ca-chain.pem
    ls $ca_path/ca-chain.pem
    chmod 444 $ca_path/ca-chain.pem
}


# Main function to generate CSR and sign a certificate
# 

create_cert_main() {
	cd $ca_path

	echo "Generating private key"
    openssl genrsa -out $ca_path/intermediate/private/$common_name.key.pem 2048

    chmod 400 $ca_path/intermediate/private/$common_name.key.pem

    echo "Generating CSR"
    openssl req \
        -config $ca_path/intermediate/openssl.cnf \
        -key $ca_path/intermediate/private/$common_name.key.pem \
        -new -sha256 \
        -out $ca_path/intermediate/private/$common_name.csr.pem \
        -subj "/C=$DEFAULT_COUNTRY/ST=$DEFAULT_STATE/L=$DEFAULT_LOCALITY/O=$DEFAULT_ORG/CN=$common_name"

    echo "Generating signed certificate from CSR"
    openssl ca \
        -config $ca_path/intermediate/openssl.cnf \
        -extensions $extensions \
        -days $DEFAULT_CERT_EXPIRY \
        -passin file:/tmp/pass \
        -notext \
        -batch \
        -md sha256 \
        -in $ca_path/intermediate/private/$common_name.csr.pem \
        -out $ca_path/intermediate/private/$common_name.cert.pem 
        #>> $ca_path/log.txt 2>&1

    echo "Your signed certificate in PEM format:"
    chmod 444 $ca_path/intermediate/private/$common_name.cert.pem
    cp $ca_path/intermediate/private/$common_name.cert.pem \
        $ca_path/$common_name.cert.pem
    ls $ca_path/$common_name.cert.pem

    echo "And the CA chain:"
    cp $ca_path/ca-chain.pem $ca_path/$common_name.ca-chain.pem
    ls $ca_path/$common_name.ca-chain.pem
}


# Script entry point
#

while getopts "ASCBp:o:c:" opt; do
  case $opt in
    A)
	    mode="create_ca"
	    ;;
    S)
	    extensions="server_cert"
	    ;;
    C)
	    extensions="client_cert"
	    ;;
    B)
	    extensions="app_cert"
	    ;;
    p)
	    ca_path=$OPTARG
	    ;;
    o)
	    org=$OPTARG
	    ;;
    c)
	    common_name=$OPTARG
	    ;;
    \?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
  esac
done

# Debug lines
#echo
#echo "mode is " $mode
#echo "extension is " $extensions
#echo "ca_path is $ca_path"
#echo "org is " $org
#echo "common_name is " $common_name
#echo


# $mode or $extensions must exist, along with $ca_path and $common_name

if [ ! \( \( "$mode" -o "$extensions" \) -a "$ca_path" -a "$common_name" \) ]
then echo "Usage: sshtool.sh (-A|-S|-C|-B) -p <CA directory path>"\
    " -c \"<Common Name>\" [-o \"<Organization Name>\"] "
	echo
	echo "Modes of operation:"
	echo "  -A 		# Create a CA, generate necessary private keys"
	echo "  -S 		# Generate a Server certificate from the CA"
	echo "  -C 		# Generate a Client certificate from the CA"
	echo "  -B 		# Generate a certificate that is both Server and Client"
	echo 
	echo "Options:"
	echo "  -p <path>	# Path to the CA folder"
	echo "  -o \"<org>\"	# Organization Name. Not strictly required"
	echo "  -c \"<CN>\"	# Common Name. This is required"

exit 2
fi



# For creating a CA, make the directory and make sure it exists before
# jumping to function

if [ "$mode" == create_ca ]
	then mkdir -p $ca_path
		if ! ( [ -d "$ca_path" ] && [ -w "$ca_path" ] )
		then echo "Could not create the base directory: $ca_path"
		exit 3
	fi
	create_ca_main
	exit
fi



# For creating a cert, make sure the CA directory exists and is writable

if [[ "$extensions" == +(server_cert|client_cert|app_cert) ]]
	then if ! ( [ -d "$ca_path" ] && [ -w "$ca_path" ] )
		then echo "Not a writable directory: $ca_path"
		exit 4
	fi
	create_cert_main
	exit
	else echo "Extensions do not look right: $extensions"
	exit 5
fi


