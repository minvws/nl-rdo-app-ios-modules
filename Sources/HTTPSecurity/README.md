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

You can tighten or relax the check with the optional commonName,  authority key identifier, the optional subject key identifier and the optional serial number of the x509 certificate. 

Be careful with the commonName check, it is easy to spoof if you forget the leading dot in the name. (A malicious hacker can create a certificate with the domain *evilhackerYOURDOMAIN*, not *evilhacker.YOURDOMAIN*)

```swift
import HTTPSecurity

let sdNRootCAG3String = """
-----BEGIN CERTIFICATE-----
MIIFdDCCA1ygAwIBAgIEAJiiOTANBgkqhkiG9w0BAQsFADBaMQswCQYDVQQGEwJO
....
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

let trustedSigners: [SigningCertificate] = [trustedSigner]
let cmsValidator = CMSSignatureValidator(trustedSigners: trustedSigners)

let payload = Data(base64Encoded:                  "WwogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMDYtMTdUMTA6MDA6MDAuMDAwKzAyMDAiLAogICJ1aXRzbGFnZGF0dW0iOiIyMDIwLTA2LTE3VDEwOjEwOjAwLjAwMCswMjAwIiwKICAicmVzdWx0YWF0IjoiTkVHQVRJRUYiLAogICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAiYWZzcHJhYWtJZCI6Mjc4NzE3Njh9LAogeyJhZm5hbWVkYXR1bSI6IjIwMjAtMTEtMDhUMTA6MTU6MDAuMDAwKzAxMDAiLAogICAidWl0c2xhZ2RhdHVtIjoiMjAyMC0xMS0wOVQwNzo1MDozOS4wMDArMDEwMCIsCiAgICJyZXN1bHRhYXQiOiJQT1NJVElFRiIsCiAgICJhZnNwcmFha1N0YXR1cyI6IkFGR0VST05EIiwKICAgImFmc3ByYWFrSWQiOjI1ODcxOTcyMTl9Cl0K"            
/*
 Base 64 encoding of 
[
 {"afnamedatum":"2020-06-17T10:00:00.000+0200",
  "uitslagdatum":"2020-06-17T10:10:00.000+0200",
  "resultaat":"NEGATIEF",
  "afspraakStatus":"AFGEROND",
  "afspraakId":27871768},
 {"afnamedatum":"2020-11-08T10:15:00.000+0100",
   "uitslagdatum":"2020-11-09T07:50:39.000+0100",
   "resultaat":"POSITIEF",
   "afspraakStatus":"AFGEROND",
   "afspraakId":2587197219}
]
*/
if cmsValidator.validate(signature: Data(), content: payload) {
 // Fails. 
}

let signature = Data(base64Encoded: "MIIKcAYJKoZIh....D6I/n")!
if cmsValidator.validate(signature: signature, content: payload) {
 // True. 
}
```



## Certificate Parser

There are three helper methods to get the [authority key identifier](https://ldapwiki.com/wiki/AuthorityKeyIdentifier), the common name or the [subject alternative names](https://en.wikipedia.org/wiki/Subject_Alternative_Name) from a [X509](https://en.wikipedia.org/wiki/X.509) certificate:

```swift
import HTTPSecurity

let parser = CertificateParser()

let authorityKeyIdentifier = parser.getAuthorityKeyIdentifier(for: certificateData) // optional Data
let commonName = parser.getCommonName(for: certificateData) // optional String
let subjectAlternativeNames = parser.getSubjectAlternativeDNSNames(for: certificateData) // optional [String]
```

All three methods are used in the TLS and CMS Validators, but can be used separately. 



## License

License is released under the EUPL 1.2 license. [See LICENSE](https://github.com/minvws/nl-rdo-app-ios-modules/blob/master/LICENSE.txt) for details.