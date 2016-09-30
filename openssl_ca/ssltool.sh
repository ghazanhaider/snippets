#!/bin/bash

# sshtool.sh -A -p <path> -o <orgname> -c <commonname>  # Create CA store and output ca chain file
# ssltool.sh -S -p <path_to_ca> -o <orgname> -c <commonname>  # Generate Server SSL cert (think https)
#

# -A = Create CA (including CA private key)
# -S = Server certificate (including private key, csr request, signed certificate and CA chain for each run)
# -C = Client certificate (same as above)
# -B = Both types of certificate, to be validated at both ends of the application

OPENSSL_CONF=/root/snippets/openssl_ca/openssl_root.cnf
ROOT_CA_EXPIRY=7300
DEFAULT_COUNTRY=CA
DEFAULT_STATE=Ontario
DEFAULT_LOCALITY=Toronto
DEFAULT_ORG=Unemployed # !!!!!!!!!!!! Need to fix this override with $org

create_ca_main() {
	cd $ca_path
	pwd
	mkdir certs crl newcerts private
	chmod 700 private/
	touch index.txt
	echo 1000 > serial
	cp $OPENSSL_CONF ./openssl.cnf     # Add root CA config file here
	echo "Generating CA priv key"
	openssl genrsa -aes256 -out private/ca.key.pem -passout pass:CHANGEME 4096
	chmod 400 private/ca.key.pem
	echo "Generating CA cert"
	openssl req -config openssl.cnf -key private/ca.key.pem -new -x509 -days $ROOT_CA_EXPIRY -sha256 -extensions v3_ca -out certs/ca.cert.pem -passin pass:CHANGEME -subj "/C=$DEFAULT_COUNTRY/ST=$DEFAULT_STATE/L=$DEFAULT_LOCALITY/O=$DEFAULT_ORG/CN=$common_name"
	chmod 444 certs/ca.cert.pem
}

create_cert_main() {
	cd $ca_path
	pwd
	echo "making cert"
}




while getopts "ASCBp:o:c:" opt; do
  case $opt in
    A)
	    mode="create_ca"
	    ;;
    S)
	    extensions="server_cert"
	    ;;
    C)
	    extensions="user_cert"
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
echo
echo "mode is " $mode
echo "extension is " $extensions
echo "ca_path is $ca_path"
echo "org is " $org
echo "common_name is " $common_name
echo


# $mode or $extensions must exist, along with $ca_path and $common_name

if [ ! \( \( "$mode" -o "$extensions" \) -a "$ca_path" -a "$common_name" \) ]
then	echo "Usage: sshtool.sh (-A|-S|-C|-B) -p <CA directory path> -c \"<Common Name>\" [-o \"<Organization Name>\"] "
	echo
	echo "Modes of operation:"
	echo "  -A 		# Create a CA, generate necessary private keys"
	echo "  -S 		# Generate a Server certificate from the CA"
	echo "  -C 		# Generate a Client certificate from the CA"
	echo "  -B 		# Generate a certificate that is both Server and Client"
	echo 
	echo "Options:"
	echo "  -p <path>	# Path to the CA folder to create or generate certs from"
	echo "  -o \"<org>\"	# Organization Name. Not strictly required"
	echo "  -c \"<CN>\"	# Common Name. This is required"

exit 2
fi



# For creating a CA, make the directory and make sure it exists before jumping to function

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

if [[ "$extensions" == +(server_cert|user_cert|app_cert) ]]
	then if ! ( [ -d "$ca_path" ] && [ -w "$ca_path" ] )
		then echo "Not a writable directory: $ca_path"
		exit 4
	fi
	create_cert_main
	exit
	else echo "Extensions do not look right: $extensions"
	exit 5
fi


