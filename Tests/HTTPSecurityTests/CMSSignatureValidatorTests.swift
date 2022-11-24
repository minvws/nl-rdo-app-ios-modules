/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import HTTPSecurity

class CMSignatureValidatorTests: XCTestCase {
	
	private var sut: CMSSignatureValidator!
	
	override func setUp() {
		
		super.setUp()
	}
	
	func test_validSignature_noTrustedSigners() {
		
		// Given
		sut = CMSSignatureValidator()
		
		// When
		let result = sut.validate(signature: ValidationData.signaturePKCS, content: ValidationData.payload)
		
		// Then
		expect(result) == false
	}
	
	func test_validSignature_validSigner() throws {
		
		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateString = try String(contentsOf: certificateUrl)
		let signingCertificate = SigningCertificate(name: "certFakePKIOverheid", certificate: certificateString)
		sut = CMSSignatureValidator(trustedSigners: [signingCertificate])
		
		// When
		let result = sut.validate(signature: ValidationData.signaturePKCS, content: ValidationData.payload)
		
		// Then
		expect(result) == true
	}
	
	func test_invalidSignature_validSigner() throws {
		
		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateString = try String(contentsOf: certificateUrl)
		let signingCertificate = SigningCertificate(name: "certFakePKIOverheid", certificate: certificateString)
		sut = CMSSignatureValidator(trustedSigners: [signingCertificate])
		
		// When
		let result = sut.validate(signature: ValidationData.signaturePKCS, content: ValidationData.wrongPayload)
		
		// Then
		expect(result) == false
	}
	
	func test_validSignature_invalidSigner() throws {
		
		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "Staat der Nederlanden Private Root CA - G1", withExtension: ".pem"))
		let certificateString = try String(contentsOf: certificateUrl)
		let signingCertificate = SigningCertificate(name: "Staat der Nederlanden Private Root CA - G1", certificate: certificateString)
		sut = CMSSignatureValidator(trustedSigners: [signingCertificate])
		
		// When
		let result = sut.validate(signature: ValidationData.signaturePKCS, content: ValidationData.payload)
		
		// Then
		expect(result) == false
	}
	
	func test_validSignature_validSigner_wrongSubjectKey() throws {
		
		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateString = try String(contentsOf: certificateUrl)
		let signingCertificate = SigningCertificate(name: "certFakePKIOverheid", certificate: certificateString, subjectKeyIdentifier: ValidationData.authorityKeyIdentifier)
		sut = CMSSignatureValidator(trustedSigners: [signingCertificate])
		
		// When
		let result = sut.validate(signature: ValidationData.signaturePKCS, content: ValidationData.payload)
		
		// Then
		expect(result) == false
	}
	
	func test_validSignature_validSigner_wrongSerial() throws {
		
		// Given
		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
		let certificateString = try String(contentsOf: certificateUrl)
		let signingCertificate = SigningCertificate(name: "certFakePKIOverheid", certificate: certificateString, rootSerial: 10000013)
		sut = CMSSignatureValidator(trustedSigners: [signingCertificate])
		
		// When
		let result = sut.validate(signature: ValidationData.signaturePKCS, content: ValidationData.payload)
		
		// Then
		expect(result) == false
	}
}
