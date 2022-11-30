#!/bin/sh

set -e

if [ $# -gt 2 ]; then
	echo "Syntax: $0 [example.json [client.crt]]"
	exit 1
fi
OPENSSL=${OPENSSL:-/opt/homebrew/Cellar/openssl\@1.1/1.1.1s/bin/openssl}
JSON=${1:-../../payload.json}
CERT=${2:-../pkio/client.crt}
CHAIN=${3:-../pkio/chain.pem}

if $OPENSSL version | grep -q LibreSSL; then
	echo Sorry - OpenSSL is needed.
	exit 1
fi

if ! $OPENSSL version | grep -q 1\.; then
	echo Sorry - OpenSSL 1.0 or higher is needed.
	exit 1
fi

#if [ $# -lt 2 -a ! -e client.crt ]; then
#	. ./gen-fake-pki-overheid.sh
#fi

JSON_B64=$(base64 -i "$JSON")
SIG_B64=$($OPENSSL cms -in "$JSON" -sign -outform DER -signer "$CERT" -certfile "$CHAIN" -binary  -keyopt rsa_padding_mode:pss | base64)

echo $SIG_B64 > pssSignature.txt
echo $JSON_B64 > pssPayload.txt

mv pssSignature.txt ../../pssSignature.txt
mv pssPayload.txt ../../pssPayload.txt
