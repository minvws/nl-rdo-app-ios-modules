#!perl

my $ca = 'ca.pem';
my $cader = $ca;
$cader =~ s/\.pem/.crt/g;

my $careal = $ca;
my $cafake = $ca;
$careal =~ s/\.pem/.real/g;
$cafake =~ s/\.pem/.fake/g;

# Fetch the root and resign it

`curl --silent https://www.identrust.com/node/935 |\
	openssl pkcs7 -inform DER -print_certs |\
	openssl x509 -out $careal` unless -f $careal;

$cmd = "cat $careal | ./resign -Ksi -d 365 > $ca; openssl x509 -in $ca -out $cafake";
system($cmd);

# Create version that can be imported into the emulator
#
`openssl x509 -in $ca -outform DER -out $cader`;

# Fetch full chain for the bananen API server

open(STDIN,'false | openssl s_client -showcerts -servername roolproductions.com -connect roolproductions.com:443 |')
	or die $!;

my $cur = undef;
my @chain = ();
while(<STDIN>) {
	$cur = '' if m/-----BEGIN/;
	$cur .= $_ if defined($cur);
	if (m/-----END/) {
		push @chain, $cur;
		undef $cur;
	};
}

# Extract the issuers so we can get the order right
my %issuer, %subject;
for my $cert (@chain) {
	open(FH,">tmp.pem") or die $!;
	print FH $cert;
	close(FH);

	$i = `openssl x509 -in tmp.pem -noout -issuer`; $i =~ s/^\w+=//;
	$s = `openssl x509 -in tmp.pem -noout -subject`; $s =~ s/^\w+=//;
	$subject{$i} = $s;
	$issuer{$i} = $cert;
};

print "Reconstructing chain:\n";
my @chain = ();
$subject = `openssl x509 -in $ca -noout -subject`; $subject =~ s/^\w+=//;
print "Root: $subject";

while($issuer{$subject}) {
	print " sub: $subject";
	push @chain, $issuer{$subject};
	delete $issuer{$subject};
	$subject = $subject{$subject};
};
print "Leaf: $subject\n";
die "Unused stuff on the chain" if keys %issuer;

# Replace the private key in each item on the chain from the servery by
# one we know; and sign it with the 'higher' up one.
#
my @filenames = ();
$idx = 1000;
for my $cert (@chain) {
	open(FH,">$idx.real") or die $!;
	print FH $cert;
	close(FH);

	$cmd = "./resign -Ksi $idx.real $ca $ca > $idx.pem && openssl x509 -days 365 -in $idx.pem -out $idx.fake";
	print "$cmd\n";
	system($cmd);
	$ca = "$idx.pem";
	push @filenames, $ca;

	# unlink "$idx.real";
	$idx++;
};

$last = pop @filenames;
$untrusted = join(' ',map { '-untrusted '.$_ } @filenames);

open(FH,">chain.pem") or die $!;
shift @chain;
for my $cert (reverse(@chain)) { print FH $cert; };
close(FH);

## Sanity check on our entire chain; with just the CA.
##
#$cmd = "openssl verify -CAfile ca.pem -purpose any $untrusted $last";
#print "Check fake with \n\t$cmd\n\n";
#system($cmd);
#$cmd =~ s/.pem/.real/g;
#print "Check real with \n\t$cmd\n\n";
#system($cmd);

## Output key identifier of leaf cerrt
##`openssl x509 -in 1002.pem -ext authorityKeyIdentifier -noout | sed -e 's/.*Identifier://' -e 's/keyid/0x04, 0x14/g' -e 's/:/, 0x/g' | grep 0x | xxd -r -p >  leaf.issuer-keyid`;
##`cat 1000.pem 1001.pem > chain.pem`
#

# Cleanup files no longer needed
system("rm tmp.pem ca.crt ca.pem chain.pem 1000.pem 1001.pem 1002.pem");

# Rename certificates to something more meaningfull
system("mv ca.real dst-root-ca-xs.pem");
system("mv ca.fake dst-root-ca-xs.fake");

system("mv 1000.real isrg-root-x1-cross-signed.pem");
system("mv 1000.fake isrg-root-x1-cross-signed.fake");

system("mv 1001.real lets-encrypt-r3.pem");
system("mv 1001.fake lets-encrypt-r3.fake");

system("mv 1002.real rool.pem");
system("mv 1002.fake rool.fake");

print("DONE renaming certificates\n");
