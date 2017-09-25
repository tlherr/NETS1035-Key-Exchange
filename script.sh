#!/bin/sh

# Files Involved:
# My Public Key: mypublic.pem
# My Private Key: myprivate.key
# Recievers Public Key: theirpublic.pem

# Signature: mysignature.sig
# Data to Encrypt: aeskey.txt

now=date(date +"(%Y-%M-%D)")
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
echo "Enter a symetric encryption key: "
read data_to_encrypt
echo $data_to_encrypt >> aeskey.txt

# Create Signature (With Private Key)
openssl dgst -sha256 -sign myprivatekey.key -out mysignature.sig important_file.txt

# Base 64 Encode Signature (For Better Transport)
base64 < signature.sig > signature.sigb64

# Confirm Authenticity (With Signers Public Key, Sig)
openssl dgst -sha256 -verify public.pem -signature signature.sig important_file.txt

# Generate a random 256 byte key
openssl rand -base64 32 > key.bin

# Encrypt File
openssl enc -aes-256-cbc -salt -in SECRET_FILE -out SECRET_FILE.enc -pass file:./someonespublickey.pem

# Decrypt the file
openssl enc -d -aes-256-cbc -in SECRET_FILE.enc -out SECRET_FILE -pass file:/myprivatekey.pem

