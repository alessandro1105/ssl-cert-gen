# First let's generate the key
sudo openssl genrsa -out ./$1.key 2048

# Now we generate the certificate
sudo openssl req -new -x509 -key ./$1.key -out ./$1.crt -days 3650 -subj /CN=$1

# Add the certificate to the Keychain
sudo security add-trusted-cert -d -r trustRoot -k ~/Library/Keychains/Development.keychain ./$1.crt