#!/usr/bin/env sh
#
TMPDIR=${TMPDIR:-/tmp}
set -e

OPENSSL=${OPENSSL:-/opt/homebrew/Cellar/openssl\@1.1/1.1.1s/bin/openssl}
JSON=${1:-../payload.json}

# Create a 'staat der nederlanden' root certificate that looks like
# the real thing. 
#
if test -f ca.key; then
	echo You propably want to run this script only once.
	exit 1
fi

$OPENSSL req -x509 -days 365 -new \
	-out ca.pem -keyout ca.key -nodes \
	-subj '/CN=/'

cat > ext.cnf.$$ <<EOM
[ subca ]
keyUsage = cRLSign, keyCertSign
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:TRUE
EOM

# Create the chain to a normal PKI leaf cert
#
$OPENSSL req -new -keyout sub-ca.key -nodes \
	-subj '/C=NL/O=Staat der Nederlanden/CN=Staat der Nederlanden Organisatie - Services G3' |\
$OPENSSL x509 \
	-extfile  ext.cnf.$$ -extensions subca \
	-req -days 365 -CAkey ca.key -CA ca.pem -set_serial 1010 -out sub-ca.pem

rm ext.cnf.$$

cat ca.pem sub-ca.pem  > full-chain.pem 
cat sub-ca.pem  > chain.pem 

# Create the root cert to import into keychain - in all formats
#
openssl x509 -in ca.pem -out ca.crt -outform DER
openssl pkcs12 -export -out ca.pfx -in ca.pem -cacerts -nodes -nokeys -passout pass:rdotoolkit
#openssl crl2pkcs7 -nocrl -certfile ca.pem -certfile sub-ca.pem -out chain.p7b

hostname=${1:-client}

cat > ext.cnf.$$ <<EOM
[ leaf ]
nsComment = For testing only and no this is not the real thing. Duh.
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:FALSE
EOM

SUBJ="/CN=/"
$OPENSSL req -new -keyout client.key -nodes -subj "${SUBJ}" |\
$OPENSSL x509 \
	-extfile  ext.cnf.$$ -extensions leaf \
	-req -days 365 -CAkey sub-ca.key -CA sub-ca.pem -set_serial 0xdeadbeefdeadbeefc0de -out client.pub
rm ext.cnf.$$

cat client.key client.pub > client.crt
openssl pkcs12 -export -out client.pfx -in client.pub -inkey client.key -certfile full-chain.pem -nodes -passout pass:rdotoolkit

# base 64 endoded payload
JSON_B64=$(base64 -i "$JSON")
# base 64 encoded signature (pss encoding) of the payload with the client cert
SIG_B64=$($OPENSSL cms -in "$JSON" -sign -outform DER -signer client.crt -certfile chain.pem -binary  -keyopt rsa_padding_mode:pss | base64)
# the authority key identifier of the client cert
KEYID=$($OPENSSL x509 -in client.crt -noout -ext authorityKeyIdentifier | sed -e 's/.*Identifier://' -e 's/keyid/0x04, 0x14/g' -e 's/:/, 0x/g')

# Cleanup
mv ca.pem noCommonNameCert.pem
echo $SIG_B64 > noCommonNameSignature.txt
echo $JSON_B64 > noCommonNamePayload.txt
echo $KEYID > noCommonNameAuthorityKeyIdentifier.txt
rm ca.* chain.pem client.* full-chain.pem sub-ca.*

echo "Done!"
