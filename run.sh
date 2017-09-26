#!/bin/sh

# This script creates two directories
# bob and alice
# Within each folder there are public and private keys

if [ ! -d ./bob ]; then
	mkdir bob;
fi

if [ ! -d ./alice ]; then
	mkdir alice;
fi

date=`date +%Y-%m-%d`

# Make Private Keys
echo "Generating Bobs Private Keys"
cd bob/
openssl genrsa > bobprivate.key
echo "Generating Bobs Public Key using Bobs Private Key"
openssl rsa -in bobprivate.key -pubout -out bobpublic.pem
cd ../

echo "Generating Alice Private Keys"
cd alice/
openssl genrsa > aliceprivate.key
echo "Generating Alices Public Key using Alices Private Key"
openssl rsa -in aliceprivate.key -pubout -out alicepublic.pem
cd ../

echo "Proceeding assuming that Bob will be sending a file to alice"
cd bob

# Make File to Encrypt
echo "Enter text to encrypt: "
read data_to_encrypt
echo $data_to_encrypt >> to_be_encrypted.txt

# Create Signature (With Private Key)
echo "Creating a signature (with our private key) to verify file integrity"
openssl dgst -sha256 -sign bobprivate.key -out bobsignature.sig to_be_encrypted.txt

# Base 64 Encode Signature (For Better Transport)
echo "Base 64 Encoding Signature for easier transport"
base64 < bobsignature.sig > bobsignature.sigb64

# Encrypt File
echo "Encrypting file: "
openssl enc -aes-256-cbc -salt -in to_be_encrypted.txt -out encrypted.enc -pass file:../alice/alicepublickey.pem

echo "Files Emailed to Alice: encrypted.enc bobsignature.sig"

cd ../
cd alice

# Confirm Authenticity (With Signers Public Key, Sig)
#echo "Alice Confirming Authenticity Using Public Key and Signature"
openssl dgst -sha256 -verify alicepublic.pem -signature ../bob/bobsignature.sig ../bob/to_be_encrypted.txt

# Decrypt the file
openssl enc -d -aes-256-cbc -in ../bob/encrypted.enc -out decrypted.txt -pass file:/aliceprivatekey.pem

