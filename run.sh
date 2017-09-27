#!/bin/sh

# This script creates two directories
# bob and alice
# Within each folder there are public and private keys

if [ ! -d ./bob ]; then
	mkdir bob;
else 
	rm -rf bob/*
fi

if [ ! -d ./alice ]; then
	mkdir alice;
else 
	rm -rf alice/*
fi

date=`date +%Y-%m-%d`

# Make Private Keys
echo "Generating Bobs Private Keys"
openssl genrsa > bob/bobprivate.key
cat bob/bobprivate.key
echo "Generating Bobs Public Key using Bobs Private Key"
openssl rsa -in bob/bobprivate.key -pubout -out bob/bobpublic.pem
cat bob/bobpublic.pem

echo "Generating Alice Private Keys"
openssl genrsa > alice/aliceprivate.key
cat alice/aliceprivate.key
echo "Generating Alices Public Key using Alices Private Key"
openssl rsa -in alice/aliceprivate.key -pubout -out alice/alicepublic.pem
cat alice/alicepublic.pem

echo "Proceeding assuming that Bob will be sending a file to alice"

phrase_to_encrypt="To be or not to be, that is the question"

# Make File to Encrypt
echo "Encrypting the following phrase: $phrase_to_encrypt"
echo $phrase_to_encrypt >> bob/to_be_encrypted.txt

# Create Signature (With Private Key)
echo "Creating a signature (with our private key) to verify file integrity"
openssl dgst -sha256 -sign bob/bobprivate.key -out bob/signature.txt.sha256 bob/to_be_encrypted.txt 
cat bob/signature.txt.sha256

# Base 64 Encode Signature (For Better Transport)
echo "Base 64 Encoding Signature for easier transport"
base64 < bob/signature.txt.sha256 > bob/bobsignature.sigb64
cat bob/bobsignature.sigb64

# Encrypt File
echo "Encrypting file: "
openssl rsautl -encrypt -pubin -inkey ./alice/alicepublic.pem -in bob/to_be_encrypted.txt -out bob/encrypted.enc.txt
cat bob/encrypted.enc.txt

echo "Files Emailed to Alice: encrypted.enc bobsignature.sigb64"

# Decrypt the file
echo "Decrypting File: (Using Alices Private Key)"
openssl rsautl -decrypt -inkey ./alice/aliceprivate.key -in bob/encrypted.enc.txt > alice/decrypted.txt

cat alice/decrypted.txt

# Confirm Authenticity (With Signers Public Key, Sig)
echo "Alice Confirming Authenticity Using Public Key and Signature"
openssl dgst -sha256 -verify bob/bobpublic.pem -signature bob/signature.txt.sha256 alice/decrypted.txt
