#!/usr/bin/env sh
#
# Used to generate a very long chain for the test/example cases
#
# Outputs:
# - deepChainCert.pem, the certificate with a deep chain
# - deepPayload.txt, the payload used
# - deepSignature.txt, the signature of payload when signed by the client

TMPDIR=${TMPDIR:-/tmp}
set -e

OPENSSL=${OPENSSL:-/opt/homebrew/Cellar/openssl\@1.1/1.1.1s/bin/openssl}
JSON=${1:-../payload.json}

if $OPENSSL version | grep -q LibreSSL; then
	echo Sorry - OpenSSL is needed.
	exit 1
fi

if ! $OPENSSL version | grep -q 1\.; then
	echo Sorry - OpenSSL 1.0 or higher is needed.
	exit 1
fi

S=0
$OPENSSL req -x509 -days 365 -new \
	-out 0.pem -keyout 0.key -nodes \
	-subj '/CN=CA'

cat > ext.cnf.$$ <<EOM
[ subca ]
nsComment = For testing only and no this is not the real thing. Duh.
keyUsage = cRLSign, keyCertSign
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:TRUE
EOM

for ss in 1 2 3 4 5 6 7 8 9
do
$OPENSSL req -new -keyout $ss.key -nodes \
	-subj "/CN=$ss deep" |
$OPENSSL x509 \
	-extfile  ext.cnf.$$ -extensions subca \
	-days 365 -req -CAkey $S.key -CA $S.pem -set_serial 1000$s -out $ss.pem
	S=$ss
done

rm ext.cnf.$$

cat [0123456789].pem  > chain.pem 
rm  [012345678].key
rm   [12345678].pem

cat > ext.cnf.$$ <<EOM
[ leaf ]
nsComment = For testing only and no this is not the real thing. Duh.
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:FALSE
EOM

SUBJ="/CN=leaf"
$OPENSSL req -new -keyout client.key -nodes -subj "${SUBJ}" |\
$OPENSSL x509 \
	-extfile  ext.cnf.$$ -extensions leaf \
	-days 365 -req -CAkey $S.key -CA $S.pem -set_serial 0xdeadbeefdeadbeefc0de -out client.pub
rm ext.cnf.$$

cat client.key client.pub > client.crt
rm client.key client.pub 9.pem 9.key

# base 64 encoded trusted certificate
CA_B64=$(base64 -i 0.pem)
# base 64 endoded payload
JSON_B64=$(base64 -i "$JSON")
# base 64 encoded signature (pss encoding) of the payload with the client cert
SIG_B64=$($OPENSSL cms -in "$JSON" -sign -outform DER -signer client.crt -certfile chain.pem -binary  -keyopt rsa_padding_mode:pss | base64)
# the authority key identifier of the client cert
KEYID=$($OPENSSL x509 -in client.crt -noout -ext authorityKeyIdentifier | sed -e 's/.*Identifier://' -e 's/keyid/0x04, 0x14/g' -e 's/:/, 0x/g')

#echo "trusted=\"$CA_B64\";\n"
#echo "keyid=[$KEYID];\n"
#echo "payload=\"$JSON_B64\";\n"
#echo "signature=\"$SIG_B64\";"

# Cleanup
mv 0.pem deepChainCert.pem
echo $SIG_B64 > deepSignature.txt
echo $JSON_B64 > deepPayload.txt
echo $KEYID > deepAuthorityKeyIdentifier.txt
rm chain.pem
rm client.crt

echo "Done!"
