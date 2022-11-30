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

class TLSValidatorTests: XCTestCase {
	
	var sut: TLSValidator!
	
	override func setUp() {
		
		super.setUp()
		sut = TLSValidator()
	}
	
	// MARK: - Subject Alternative Name
	
	func test_subjectAlternativeNames_realLeaf() throws {
		
		// Given
		// getting the chain certificates:
		// openssl s_client -showcerts -servername holder-api.coronacheck.nl -connect holder-api.coronacheck.nl:443
		
		// When
		let result = sut.validateSubjectAlternativeDNSName(
			"holder-api.coronacheck.nl",
			for: try getCertificateData("holder-api.coronacheck.nl")
		)
		
		// Then
		expect(result) == true
	}
	
	func test_subjectAlternativeNames_fakeLeaf() throws {
		
		// Given
		// Use emailAndIP.sh to generate this certificate
		let certificateData = try getCertificateData("emailAndIPCert")
		
		// When
		
		// Then
		expect(self.sut.validateSubjectAlternativeDNSName("test1", for: certificateData)) == true
		expect(self.sut.validateSubjectAlternativeDNSName("test2", for: certificateData)) == true
		// check that we do not see the non DNS entries. IP address is a bit of an edge case. Perhaps
		// we should allow that to match.
		expect(self.sut.validateSubjectAlternativeDNSName("fo@bar", for: certificateData)) == false
	}
	
	func test_subjectAlternativeNames_mismatchSubjectAlternativeName_and_commonName() throws {
		
		// Given
		// UsemismatchSANAndCommonName.sh to generate this certificate
		let certificateData = try getCertificateData("mismatchSANAndCommonNameCert")
		
		// When
		
		// Then
		expect(self.sut.validateSubjectAlternativeDNSName("foobar.nl", for: certificateData)) == true
		expect(self.sut.validateSubjectAlternativeDNSName("oobar.nl", for: certificateData)) == false
	}
	
	func test_subjectAlternativeNames_subjectAlternativeName_partialyMatches_commonName() throws {
		
		// Example of a cert we should not let pass - even though it looks good.
		
		// Given
		// Use partialMismatchSANAndCommonName.sh to generate this certificate
		
		// When
		let result = sut.validateSubjectAlternativeDNSName(
			"foobar.nl",
			for: try getCertificateData("partialMismatchSANAndCommonNameCert")
		)
		// Then
		expect(result) == false
	}
	
	func test_subjectAlternativeNames_certWithCNrightAndNoRelevantSAN() throws {
		
		// Given
		// Use ipOnly.sh to generate this certificate
		
		let result = sut.validateSubjectAlternativeDNSName(
			"foobar.nl",
			for: try getCertificateData("ipOnlyCert")
		)
		
		// Then
		expect(result) == false
	}
	
	func test_compare_identicalCertificates() throws {
		
		// Given
		// getting the chain certificates:
		// openssl s_client -showcerts -servername holder-api.coronacheck.nl -connect holder-api.coronacheck.nl:443
		
		// When
		let result = sut.compare(
			try getCertificateData("holder-api.coronacheck.nl"),
			with: try getCertificateData("holder-api.coronacheck.nl")
		)
		
		// Then
		expect(result) == true
	}
	
	func test_compare_differentCertificates() throws {
		
		// Given
		// getting the chain certificates:
		// openssl s_client -showcerts -servername holder-api.coronacheck.nl -connect holder-api.coronacheck.nl:443
		// Use Staat der Nederlanden Private Root CA - G1 certificate
		
		// When
		let result = sut.compare(
			try getCertificateData("holder-api.coronacheck.nl"),
			with: try getCertificateData("Staat der Nederlanden Private Root CA - G1")
		)
		
		// Then
		expect(result) == false
	}
}
