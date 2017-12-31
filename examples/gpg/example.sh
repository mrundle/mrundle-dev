#!/bin/bash
email=m.n.rundle@gmail.com
plaintext=plaintext.txt
ciphertext=ciphertext.txt

# generate key
gpg --gen-key

# print public key
gpg --armor --export $email > mykey.asc

# import a key
gpg --import fake-import.asc

# encrypt
gpg --output $ciphertext --encrypt --recipient $email $plaintext

# encrypt (ascii armor)
gpg --armor --output $ciphertext --encrypt --recipient $email $plaintext
