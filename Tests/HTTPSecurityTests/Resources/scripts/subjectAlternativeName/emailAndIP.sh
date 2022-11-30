#!/usr/bin/env sh
#
# Used to generate a certificate with email and IP in the subject alternative name
#
# Outputs:
# - emailAndIPCert.pem, the certificate with a email and IP as SAN

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
	-addext "subjectAltName=DNS:test1,DNS:test2,email:fo@bar,IP:1.2.3.4" \
	-subj '/CN=Staat der Nederlanden Root CA - G3/O=Staat der Nederlanden/C=NL' \
	-out ca.pem -keyout ca.key -nodes

# Cleanup
rm ca.key
mv ca.pem ../../emailAndIPCert.pem
