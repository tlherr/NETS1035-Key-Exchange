#!/bin/sh

# Files Involved:
# My Public Key: mypublic.pem
# My Private Key: myprivate.key
# Recievers Public Key: theirpublic.pem

# Signature: mysignature.sig
# Data to Encrypt: to_be_encrypted.txt

date=`date +%Y-%m-%d`
dirname="$date-aes-test"
echo "Making a new directory: $dirname"
mkdir $dirname;
cd $dirname;

# Make Private Key
echo "Generating a Private Key"
openssl genrsa > myprivate.key
echo "Generating a Public Key using Private Key"
openssl rsa -in myprivate.key -pubout -out mypublic.pem

# Make File to Encrypt
echo "Enter text to encrypt: "
read data_to_encrypt
echo $data_to_encrypt >> to_be_encrypted.txt

# Create Signature (With Private Key)
echo "Creating a signature (with our private key) to verify file integrity"
openssl dgst -sha256 -sign myprivatekey.key -out mysignature.sig to_be_encrypted.txt

# Base 64 Encode Signature (For Better Transport)
echo "Base 64 Encoding Signature for easier transport"
base64 < signature.sig > signature.sigb64

# Confirm Authenticity (With Signers Public Key, Sig)
#echo ""
#openssl dgst -sha256 -verify public.pem -signature signature.sig to_be_encrypted.txt

# Encrypt File
echo "Encrypting file: "
openssl enc -aes-256-cbc -salt -in to_be_encrypted.txt -out encrypted.enc -pass file:./theirpublickey.pem

# Decrypt the file
# openssl enc -d -aes-256-cbc -in SECRET_FILE.enc -out SECRET_FILE -pass file:/myprivatekey.pem

echo "Process complete: file encrypted.enc is now ready to be sent along with signature.sigb64"
