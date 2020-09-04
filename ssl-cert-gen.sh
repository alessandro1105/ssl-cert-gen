DEFAULT_CA_KEY=~/.dev/ca.key
DEFAULT_CA_PEM=~/.dev/ca.pem

FILENAME=${2:-$1}

CA_KEY=${3:-$DEFAULT_CA_KEY}
CA_PEM=${4:-$DEFAULT_CA_PEM}

# Let's generate a CA key and cert
# if they do not exists and add them
# to the System.keychain
if [ ! -f $CA_KEY ]; then
    sudo openssl genrsa -out $CA_KEY 2048
    sudo openssl req -x509 -new -nodes -key $CA_KEY -sha256 -days 3650 -out $CA_PEM -subj /CN="Development CA"
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $CA_PEM
fi

openssl genrsa -out $FILENAME.key 2048
openssl req -new -key $FILENAME.key -out $FILENAME.csr -subj /CN=$1


cat > $FILENAME.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $1
EOF

# Now we generate the certificate and the key
openssl x509 -req -in $FILENAME.csr -CA $CA_PEM -CAkey $CA_KEY -CAcreateserial -out $FILENAME.crt -days 3650 -sha256 -extfile $FILENAME.ext