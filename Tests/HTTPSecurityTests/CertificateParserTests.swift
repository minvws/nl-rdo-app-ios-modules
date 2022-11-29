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
		// Use Staat der Nederlanden Private Root CA - G1 certificate

		// When
		let key = sut.getAuthorityKeyIdentifier(for: try getCertificateData("Staat der Nederlanden Private Root CA - G1"))

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
	
	func test_getAuthorityKeyIdentifier_fakePKIOverheidCert_shouldNotBeNil() throws {
		
		// Given
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use cleanup.sh to remove the unneeded files

		// When
		let key = sut.getAuthorityKeyIdentifier(for: try getCertificateData("fakePKIOverheidCert"))
		
		// Then
		expect(key) != nil
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
		// Use noCommonName.sh to generate this certificate
		
		// When
		let name = sut.getCommonName(for: try getCertificateData("noCommonNameCert"))
		
		// Then
		expect(name) == nil
	}
	
	func test_getCommonName_PrivateRootCA_G1() throws {
		
		// Given
		// Use Staat der Nederlanden Private Root CA - G1 certificate
		
		// When
		let name = sut.getCommonName(for: try getCertificateData("Staat der Nederlanden Private Root CA - G1"))

		// Then
		expect(name) == "Staat der Nederlanden Private Root CA - G1"
	}
	
	func test_getCommonName_RootCA_G3() throws {
		
		// Given
		// Use Staat der Nederlanden Root CA - G3 certificate
		
		// When
		let name = sut.getCommonName(for: try getCertificateData("Staat der Nederlanden Root CA - G3"))
		
		// Then
		expect(name) == "Staat der Nederlanden Root CA - G3"
	}

	// MARK: - Subject Alternative Name

	func test_subjectAlternativeNames_realCertificate() throws {

		// Given
		// getting the chain certificates:
		// openssl s_client -showcerts -servername holder-api.coronacheck.nl -connect holder-api.coronacheck.nl:443

		// When
		let sans = sut.getSubjectAlternativeDNSNames(for: try getCertificateData("holder-api.coronacheck.nl"))

		// Then
		expect(sans).to(haveCount(1))
		expect(sans?.first) == "holder-api.coronacheck.nl"
	}

	func test_subjectAlternativeNames_fakeLeaf() throws {

		// Given
		// Use emailAndIP.sh to generate this certificate

		// When
		let sans = sut.getSubjectAlternativeDNSNames(for: try getCertificateData("emailAndIPCert"))

		// Then
		expect(sans).to(haveCount(2))
		// check that we skip the IP, otherName and email entry.
		expect(sans).to(contain("test1"))
		expect(sans).to(contain("test2"))
		expect(sans).toNot(contain("1.2.3.4"))
		expect(sans).toNot(contain("fo@bar"))

		// OpenSSL seems to keep the order the same.
		expect(sans?.first) == "test1"
		expect(sans?.last) == "test2"
	}
}
