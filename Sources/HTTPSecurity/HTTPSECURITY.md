# HTTP Security

Communicating with a server in Swift is easy. Making sure that the server is actually the real server and not a fraudulent server is a lot harder. As we are sending highly personal data to and from our servers, it is vital that we thouroughly check the server and its certificates. 

To inspect the certificates for an URL request, we can use the [URLSessionDelegate](https://developer.apple.com/documentation/foundation/urlsessiondelegate) protocol. Make a class that implements the `func urlSession(URLSession, didReceive: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)` method to catch the incoming certificates and set that as the delegate for your URLSession. 

The chain of certificates (serverTrust) and the host can be found with

```swift
guard challenge?.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
    let serverTrust = challenge?.protectionSpace.serverTrust, 
    let host = challenge?.protectionSpace.host else {
			
			print("invalid authenticationMethod")
			completionHandler(.performDefaultHandling, nil)
			return
}
		
let policies = [SecPolicyCreateSSL(true, host as CFString)]
```

You can create a hardcode list of trusted certificates (or download a list from your own API if you need dynamic trust). Transforming a certificate can be something like:

```swift
let trustedCertificateString = """
-----BEGIN CERTIFICATE-----
MIIJlj....YljxQ==
-----END CERTIFICATE-----
"""
let trustedCertificateData = Data(trustedCertificateString.utf8)
```

We took a three way approach to checking the certificates. 

- Check if the certificates actually pass the default OS certificate checks (App Transport Security).
- Check if the certificate matches the certificate we are expecting (Transport Layer Security).
- See if the content is signed with a trusted certificate (Signature Validation)



## App Transport Security

The AppTransportSecurityChecker class is a helper to check the incoming certificates against the trust list (an array of trusted certificates). 

### Usage

Call the check method of the `AppTransportSecurityChecker` in 

```swift
import HTTPSecurity
import Security	

func checkATS(
		serverTrust: SecTrust,
		policies: [SecPolicy],
		trustedCertificates: [Data]) -> Bool {
		
    let appTransportSecurityChecker = AppTransportSecurityChecker()		
  
    // Prevent further checks if the AppTransportSecurity declined the certificate
		guard appTransportSecurityChecker.check(
			serverTrust: serverTrust,
			policies: policies,
			trustedCertificates: trustedCertificates) else {
			print("Bail on ATS")
			return false
		}
```



## Transport Layer Security

### Usage

The `TLSValidor` class has two helper methods to assist Transport Layer Security validation. We can [compare the subject alternative name](validateSubjectAlternativeDNSName) with the expected hostname, and we can [compare the certificate with a trusted certificate](compare)

#### validateSubjectAlternativeDNSName

We check if the [Subject Alertnative Name](https://en.wikipedia.org/wiki/Subject_Alternative_Name) of a certificate is the [fully qualified domain name](https://en.wikipedia.org/wiki/Fully_qualified_domain_name) we expect it to be. 

```swift
import HTTPSecurity
import Security

func checkSubjectAlternativeName(
	serverTrust: SecTrust,
	fullyQualifiedDomainName: String) -> Bool {
			
	var matchesFQDN = false
  let tlsValidator = TLSValidator()
	for index in 0 ..< SecTrustGetCertificateCount(serverTrust) {
		if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, index) {
      
      // Convert SecCertificate to our Certificate struct
			let serverCert = Certificate(certificate: serverCertificate)
      
      // Display the SAN
      let san = tlsValidator.getSubjectAlternativeDNSNames(for: serverCert.data)
      print("The Subject Alternative Name is \(san)")
      
      // Validate if the SAN matches the expected fqdn
			if tlsValidator.validateSubjectAlternativeDNSName(fullyQualifiedDomainName, for: serverCert.data) {
				matchesFQDN = true
				print("Certificate matched SAN \(fullyQualifiedDomainName)")
			}
		}
	}
	return validFQDN
} 
```

#### compare

This package has a method to compare two certificates. Besides the hash of the certificate, it will compare the serial number, the subject key identifier and the public key of the the two certificates. 

```swift
import HTTPSecurity
import Security

func compareCertificate(
	serverTrust: SecTrust,
	trustedCertificateData: Data) -> Bool {
			
	var validCertificate = false
  let tlsValidator = TLSValidator()
	for index in 0 ..< SecTrustGetCertificateCount(serverTrust) {
		if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, index) {
      
      // Convert SecCertificate to our Certificate struct
			let serverCert = Certificate(certificate: serverCertificate)
 
      // Check if the certificate matches the expected certificate
      validCertificate = validCertificate || tlsValidator.compare(serverCert.data with: trustedCertificateData)
		}
	}
	return validCertificate
}

```



## Signature Validation

The third path of the security measures is validation of the signature. We've defined a `SignatureValidation` Protocol:

```swift
/// Validate a signature
/// - Parameters:
///   - signature: the signature to validate
///   - content: the signed content
/// - Returns: True if the signature is a valid signature
func validate(signature: Data, content: Data) -> Bool
```

The package provides two implementations of this protocol, you can create your own implementation if required. 

### Signature Validation Usage

#### Always Allow

For testing and debugging there is an `AlwaysAllowSignatureValidator` implementation that will allow any signature. 

```swift
import HTTPSecurity

let content = Data("This is awesome".utf8)
let signature = Data()
if AlwaysAllowSignatureValidator().validate(signature: signature, content: content) {
 // Always true 
}
```



#### Cryptographic Message Syntax

Another implementation of the SignatureValidation Protocol is the `CMSSignatureValidator`, based upon the [Cryptographic Message Syntax](https://en.wikipedia.org/wiki/Cryptographic_Message_Syntax). Just as with the TLS certificate, we are very carefull with which certificates we accept for signatures. 

```swift
import HTTPSecurity

let sdNRootCAG3String = """
-----BEGIN CERTIFICATE-----
MIIFdDCCA1ygAwIBAgIEAJiiOTANBgkqhkiG9w0BAQsFADBaMQswCQYDVQQGEwJO
TDEeMBwGA1UECgwVU3RhYXQgZGVyIE5lZGVybGFuZGVuMSswKQYDVQQDDCJTdGFh
dCBkZXIgTmVkZXJsYW5kZW4gUm9vdCBDQSAtIEczMB4XDTEzMTExNDExMjg0MloX
DTI4MTExMzIzMDAwMFowWjELMAkGA1UEBhMCTkwxHjAcBgNVBAoMFVN0YWF0IGRl
ciBOZWRlcmxhbmRlbjErMCkGA1UEAwwiU3RhYXQgZGVyIE5lZGVybGFuZGVuIFJv
b3QgQ0EgLSBHMzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL4yolQP
cPssXFnrbMSkUeiFKrPMSjTysF/zDsccPVMeiAho2G89rcKezIJnByeHaHE6n3WW
IkYFsO2tx1ueKt6c/DrGlaf1F2cY5y9JCAxcz+bMNO14+1Cx3Gsy8KL+tjzk7FqX
xz8ecAgwoNzFs21v0IJyEavSgWhZghe3eJJg+szeP4TrjTgzkApyI/o1zCZxMdFy
KJLZWyNtZrVtB0LrpjPOktvA9mxjeM3KTj215VKb8b475lRgsGYeCasH/lSJEULR
9yS6YHgamPfJEf0WwTUaVHXvQ9Plrk7O53vDxk5hUUurmkVLoR9BvUhTFXFkC4az
5S6+zqQbwSmEorXLCCN2QyIkHxcE1G6cxvx/K2Ya7Irl1s9N9WMJtxU51nus6+N8
6U78dULI7ViVDAZCopz35HCz33JvWjdAidiFpNfxC95DGdRKWCyMijmev4SH8RY7
Ngzp07TKbBlBUgmhHbBqv4LvcFEhMtwFdozL92TkA1CvjJFnq8Xy7ljY3r735zHP
bMk7ccHViLVlvMDoFxcHErVc0qsgk7TmgoNwNsXNo42ti+yjwUOH5kPiNL6VizXt
BznaqB16nzaeErAMZRKQFWDZJkBE41ZgpRDUajz9QdwOWke275dhdU/Z/seyHdTt
XUmzqWrLZoQT1Vyg3N9udwbRcXXIV2+vD3dbAgMBAAGjQjBAMA8GA1UdEwEB/wQF
MAMBAf8wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBRUrfrHkleuyjWcLhL75Lpd
INyUVzANBgkqhkiG9w0BAQsFAAOCAgEAMJmdBTLIXg47mAE6iqTnB/d6+Oea31BD
U5cqPco8R5gu4RV78ZLzYdqQJRZlwJ9UXQ4DO1t3ApyEtg2YXzTdO2PCwyiBwpwp
LiniyMMB8jPqKqrMCQj3ZWfGzd/TtiunvczRDnBfuCPRy5FOCvTIeuXZYzbB1N/8
Ipf3YF3qKS9Ysr1YvY2WTxB1v0h7PVGHoTx0IsL8B3+A3MSs/mrBcDCw6Y5p4ixp
gZQJut3+TcCDjJRYwEYgr5wfAvg1VUkvRtTA8KCWAg8zxXHzniN9lLf9OtMJgwYh
/WA9rjLA0u6NpvDntIJ8CsxwyXmA+P5M9zWEGYox+wrZ13+b8KKaa8MFSu1BYBQw
0aoRQm7TIwIEC8Zl3d1Sd9qBa7Ko+gE4uZbqKmxnl4mUnrzhVNXkanjvSr0rmj1A
fsbAddJu+2gw7OyLnflJNZoaLNmzlTnVHpL3prllL+U9bTpITAjc5CgSKL59NVzq
4BZ+Extq1z7XnvwtdbLBFNUjA9tbbws+eC8N3jONFrdI54OagQ97wUNNVQQXOEpR
1VmiiXTTn74eS9fGbbeIJG9gkaSChVtWQbzQRKtqE77RLFi3EjNYsjdj3BP1lB0/
QFH1T/U67cjF68IeHRaVesd+QnGTbksVtzDfqu1XhUisHWrdOWnk4Xl4vs4Fv6EM
94B7IWcnMFk=
-----END CERTIFICATE-----
"""

let trustedSigner: SigningCertificate = SigningCertificate(
   name: "Staat der Nederlanden Root CA - G3", 
   certificate: sdNRootCAG3String, 
   commonName: ".rdobeheer.nl", 
		authorityKeyIdentifier: nil,
		subjectKeyIdentifier: Data([0x04, 0x14, /* keyID starts here: */ 0x54, 0xAD, 0xFA, 0xC7, 0x92, 0x57, 0xAE, 0xCA, 0x35, 0x9C, 0x2E, 0x12, 0xFB, 0xE4, 0xBA, 0x5D, 0x20, 0xDC, 0x94, 0x57]),
		rootSerial: 10003001
)
```







```swift
import HTTPSecurity

let trustedSigners: [SigningCertificate] = ...
let cmsValidator = CMSSignatureValidator(trustedSigners: trustedSigners)

let content = Data("This is awesome".utf8)
let signature = Data()
if cmsValidator.validate(signature: signature, content: content) {
 // Fails. 
}



```



## License

License is released under the EUPL 1.2 license. [See LICENSE](https://github.com/minvws/nl-rdo-app-ios-modules/blob/master/LICENSE.txt) for details.