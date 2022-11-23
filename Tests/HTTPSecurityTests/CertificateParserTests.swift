/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import HTTPSecurity
@testable import HTTPSecurityObjC

class CertificateParserTests: XCTestCase {
	
	private var sut: CertificateParser!
	
	override func setUp() {
		
		super.setUp()
		sut = CertificateParser()
	}
	
	// MARK: - Authority Key Identifier
	
	func test_getAuthorityKeyIdentifier_privateRoot_shouldBeNil() throws {

		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "Staat der Nederlanden Private Root CA - G1", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let key = sut.getAuthorityKeyIdentifier(for: certificateData)

		// Then
		expect(key) == nil
	}

	func test_getAuthorityKeyIdentifier_emptyData_shouldBeNil() {
		
		// Given
		let certificateData = Data()
		
		// When
		let key = sut.getAuthorityKeyIdentifier(for: certificateData)
		
		// Then
		expect(key) == nil
	}
	
	func test_getAuthorityKeyIdentifier_certRealLeaf_shouldMatch() throws {
		
		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certRealLeaf", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)
		
		let expectedAuthorityKeyIdentifier = Data([0x04, 0x14, /* keyID starts here: */ 0x14, 0x2e, 0xb3, 0x17, 0xb7, 0x58, 0x56, 0xcb, 0xae, 0x50, 0x09, 0x40, 0xe6, 0x1f, 0xaf, 0x9d, 0x8b, 0x14, 0xc2, 0xc6])

		// When
		let key = sut.getAuthorityKeyIdentifier(for: certificateData)
		
		// Then
		expect(key) == expectedAuthorityKeyIdentifier
	}
	
	// MARK: - Common Name
	
	func test_getCommonName_emptyData() {
		
		// Given
		let certificateData = Data()
		
		// When
		let name = sut.getCommonName(for: certificateData)
		
		// Then
		expect(name) == nil
	}
	
	func test_getCommonName_noCommonName() throws {
		
		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certWithoutCN", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)
		
		// When
		let name = sut.getCommonName(for: certificateData)
		
		// Then
		expect(name) == nil
	}
	
	func test_getCommonName_PrivateRootCA_G1() throws {
		
		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "Staat der Nederlanden Private Root CA - G1", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)
		
		// When
		let name = sut.getCommonName(for: certificateData)

		// Then
		expect(name) == "Staat der Nederlanden Private Root CA - G1"
	}
	
	func test_getCommonName_RootCA_G3() throws {
		
		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "Staat der Nederlanden Root CA - G3", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)
		
		// When
		let name = sut.getCommonName(for: certificateData)
		
		// Then
		expect(name) == "Staat der Nederlanden Root CA - G3"
	}
	
	func test_getCommonName_EVRootCA() throws {
		
		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "Staat der Nederlanden EV Root CA", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)
		
		// When
		let name = sut.getCommonName(for: certificateData)
		
		// Then
		expect(name) == "Staat der Nederlanden EV Root CA"
	}
	
	// MARK: - Subject Alternative Name

	func test_subjectAlternativeNames_realLeaf() throws {

		// Chain that is identical in subjectKeyIdentifier, issuerIdentifier, etc
		// to a real one - but fake from the root down.
		//
		// See the Scripts directory:
		//  gen_fake_bananen.sh         - takes real chain and makes a fake one from it.
		//  gen_fake_cms_signed_json.sh - uses that to sign a bit of json.
		//  gen_code.pl                 - generates below hardcoded data.
		//
		// For the scripts that have generated below.
		//
		// File:       : 1002.real
		// SHA256 (DER): 19:C4:79:A1:D9:E9:BD:B3:D7:38:E8:41:45:70:16:FB:D8:15:C0:6B:71:96:12:F7:00:9A:1A:C7:E1:9B:F3:53
		// Subject     : CN = api-ct.bananenhalen.nl
		// Issuer      : C = US, O = Let's Encrypt, CN = R3
		//

		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certRealLeaf", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let sans = sut.getSubjectAlternativeDNSNames(for: certificateData)

		// Then
		expect(sans).to(haveCount(1))
		expect(sans?.first) == "api-ct.bananenhalen.nl"
	}

	func test_subjectAlternativeNames_fakeLeaf() throws {

		// Bizarre cert with odd extensions.
		// Regenerate with openssl req -new -x509 -subj /CN=foo/ \
		//      -addext "subjectAltName=otherName:foodofoo, otherName:1.2.3.4;UTF8,DNS:test1,DNS:test2,email:fo@bar,IP:1.2.3.4"  \
		//      -nodes -keyout /dev/null |\
		//            openssl x509 | pbcopy
		//

		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certWithEmailAndIP", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let sans = sut.getSubjectAlternativeDNSNames(for: certificateData)

		// Then
		expect(sans).to(haveCount(2))
		// check that we skip the IP, otherName and email entry.
		expect(sans).to(contain("test1"))
		expect(sans).to(contain("test2"))
		expect(sans).toNot(contain("1.2.3.4"))

		// OpenSSL seems to keep the order the same.
		expect(sans?.first) == "test1"
		expect(sans?.last) == "test2"
	}
}
