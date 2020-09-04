DEFAULT_CA_KEY=~/.dev/ca.key
DEFAULT_CA_PEM=~/.dev/ca.pem

CA_KEY=${2:-$DEFAULT_CA_KEY}
CA_PEM=${3:-$DEFAULT_CA_PEM}

# Let's generate a CA key and cert
# if they do not exists and add them
# to the System.keychain
if [ ! -f $CA_KEY ]; then
    sudo openssl genrsa -out $CA_KEY 2048
    sudo openssl req -x509 -new -nodes -key $CA_KEY -sha256 -days 3650 -out $CA_PEM -subj /CN="Development CA"
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $CA_PEM
fi

openssl genrsa -out $1.key 2048
openssl req -new -key $1.key -out $1.csr -subj /CN=$1


cat > $1.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $1
EOF

# Now we generate the certificate and the key
openssl x509 -req -in $1.csr -CA $CA_PEM -CAkey $CA_KEY -CAcreateserial -out $1.crt -days 825 -sha256 -extfile $1.ext