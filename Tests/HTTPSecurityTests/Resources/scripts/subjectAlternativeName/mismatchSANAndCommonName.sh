#!/usr/bin/env sh
#
# Used to generate a certificate with mismatch between SAN and CN
#
# Outputs:
# - mismatchSANAndCommonNameCert.pem, the certificate with a mismatch between SAN and CN

TMPDIR=${TMPDIR:-/tmp}
set -e

OPENSSL=${OPENSSL:-/opt/homebrew/Cellar/openssl\@1.1/1.1.1s/bin/openssl}

if $OPENSSL version | grep -q LibreSSL; then
	echo Sorry - OpenSSL is needed.
	exit 1
fi

if ! $OPENSSL version | grep -q 1\.; then
	echo Sorry - OpenSSL 1.0 or higher is needed.
	exit 1
fi

$OPENSSL req -x509 -days 365 -new \
	-addext "subjectAltName=DNS:foobar.nl,DNS:someothercustomer.com" \
	-subj '/CN=Foobar Center 100' \
	-out ca.pem -keyout ca.key -nodes

# Cleanup
rm ca.key
mv ca.pem ../../mismatchSANAndCommonNameCert.pem
