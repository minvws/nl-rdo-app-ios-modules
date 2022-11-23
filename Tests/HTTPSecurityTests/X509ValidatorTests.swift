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

class X509ValidatorTests: XCTestCase {
	
	private var sut: X509Validator!
	
	override func setUp() {
		
		super.setUp()
		sut = X509Validator()
	}
	
	func test_validateCMSSignature_padding_pkcs_validPayload() throws {

		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validateCMSSignature(
			ValidationData.signaturePKCS,
			contentData: ValidationData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl"
		)

		// Then
		expect(validation) == true
	}

	func test_validateCMSSignature__padding_pkcs_wrongPayload() throws {

		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validateCMSSignature(
			ValidationData.signaturePKCS,
			contentData: ValidationData.wrongPayload,
			certificateData: certificateData,
			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl"
		)

		// Then
		expect(validation) == false
	}

	func test_validateCMSSignature__padding_pss_validPayload() throws {

		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validateCMSSignature(
			ValidationData.signaturePSS,
			contentData: ValidationData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl"
		)

		// Then
		expect(validation) == true
	}

	func test_validateCMSSignature__padding_pss_wrongPayload() throws {

		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validateCMSSignature(
			ValidationData.wrongPayload,
			contentData: ValidationData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl"
		)

		// Then
		expect(validation) == false
	}

	func test_validateCMSSignature__test_pinning_wrongCommonName() throws {

		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validateCMSSignature(
			ValidationData.signaturePKCS,
			contentData: ValidationData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
			requiredCommonNameContent: ".coronacheck.nl"
		)

		// Then
		expect(validation) == false
	}

	func test_validateCMSSignature__test_pinning_commonNameAsPartOfDomain() throws {

		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validateCMSSignature(
			ValidationData.signaturePKCS,
			contentData: ValidationData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl.xx.nl"
		)

		// Then
		expect(validation) == false
	}

	func test_validateCMSSignature__test_pinning_emptyCommonName() throws {

		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validateCMSSignature(
			ValidationData.signaturePKCS,
			contentData: ValidationData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
			requiredCommonNameContent: ""
		)

		// Then
		expect(validation) == true
	}

	func test_validateCMSSignature__test_pinning_emptyAuthorityKeyIdentifier() throws {

		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validateCMSSignature(
			ValidationData.signaturePKCS,
			contentData: ValidationData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: nil,
			requiredCommonNameContent: "coronatester.nl"
		)

		// Then
		expect(validation) == true
	}

	func test_validateCMSSignature__test_pinning_emptyAuthorityKeyIdentifier_emptyCommonName() throws {

		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validateCMSSignature(
			ValidationData.signaturePKCS,
			contentData: ValidationData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: nil,
			requiredCommonNameContent: ""
		)

		// Then
		expect(validation) == true
	}

	func test_validateCMSSignature_verydeep() throws {

		// Use long-chain.sh to generate this certificate (0.pem -> certDeepChain.pem)

		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certDeepChain", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validateCMSSignature(
			ValidationData.deepSignature,
			contentData: ValidationData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: ValidationData.deepAuthorityKeyIdentifier,
			requiredCommonNameContent: "leaf"
		)

		// Then
		expect(validation) == true
	}

	func test_validateCMSSignature_invalidAuthorityKeyIdentifier() throws {

		// Use long-chain.sh to generate this certificate

		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certDeepChain", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validateCMSSignature(
			ValidationData.deepSignature,
			contentData: ValidationData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester.nl"
		)

		// Then
		expect(validation) == false
	}

	func test_validateCMSSignature_noCommonName() throws {

		// Use long-chain.sh to generate this certificate

		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certWithoutCN", withExtension: ".pem"))
		let certificateData = try Data(contentsOf: certificateUrl)

		// When
		let validation = sut.validateCMSSignature(
			ValidationData.signatureNoCommonName,
			contentData: ValidationData.payload,
			certificateData: certificateData,
			authorityKeyIdentifier: ValidationData.noCommonNameAuthorityKeyIdentifier,
			requiredCommonNameContent: ".coronatester..nl"
		)

		// Then
		expect(validation) == false
	}
}
