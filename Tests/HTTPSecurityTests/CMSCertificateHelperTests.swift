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

class CMSCertificateHelperTests: XCTestCase {
	
	private var sut: CMSCertificateHelper!
	
	override func setUp() {
		
		super.setUp()
		sut = CMSCertificateHelper()
	}
	
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
}
