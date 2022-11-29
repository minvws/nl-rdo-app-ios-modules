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
	
	func test_validSignature_noTrustedSigners() throws {
		
		// Given
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use sigh.sh to generate the pkcs1 signature
		// Use cleanup.sh to remove the unneeded files
		sut = CMSSignatureValidator()
		
		// When
		let result = sut.validate(
			signature: try getbase64EncodedData("pkcs1Signature"),
			content: try getbase64EncodedData("pkcs1Payload")
		)
		
		// Then
		expect(result) == false
	}
	
	func test_validSignature_validSigner() throws {
		
		// Given
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use sigh.sh to generate the pkcs1 signature
		// Use cleanup.sh to remove the unneeded files
		let signingCertificate = SigningCertificate(
			name: "certFakePKIOverheid",
			certificate: try getCertificateString("fakePKIOverheidCert")
		)
		sut = CMSSignatureValidator(trustedSigners: [signingCertificate])
		
		// When
		let result = sut.validate(
			signature: try getbase64EncodedData("pkcs1Signature"),
			content: try getbase64EncodedData("pkcs1Payload")
		)
		
		// Then
		expect(result) == true
	}
	
	func test_invalidSignature_validSigner() throws {
		
		// Given
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use sigh.sh to generate the pkcs1 signature
		// Use cleanup.sh to remove the unneeded files
		let signingCertificate = SigningCertificate(
			name: "certFakePKIOverheid",
			certificate: try getCertificateString("fakePKIOverheidCert")
		)
		sut = CMSSignatureValidator(trustedSigners: [signingCertificate])
		
		// When
		let result = sut.validate(
			signature: try getbase64EncodedData("pkcs1Signature"),
			content: try getbase64EncodedData("pkcs1Payload") + Data("Wrong".utf8)
		)
		
		// Then
		expect(result) == false
	}
	
	func test_validSignature_invalidSigner() throws {
		
		// Given
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use sigh.sh to generate the pkcs1 signature
		// Use cleanup.sh to remove the unneeded files
		let signingCertificate = SigningCertificate(
			name: "certFakePKIOverheid",
			certificate: try getCertificateString("Staat der Nederlanden Private Root CA - G1")
		)
		sut = CMSSignatureValidator(trustedSigners: [signingCertificate])
		
		// When
		let result = sut.validate(
			signature: try getbase64EncodedData("pkcs1Signature"),
			content: try getbase64EncodedData("pkcs1Payload") + Data("Wrong".utf8)
		)
		
		// Then
		expect(result) == false
	}
	
	func test_validSignature_validSigner_wrongSubjectKey() throws {
		
		// Given
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use sigh.sh to generate the pkcs1 signature
		// Use cleanup.sh to remove the unneeded files
		let signingCertificate = SigningCertificate(
			name: "certFakePKIOverheid",
			certificate: try getCertificateString("fakePKIOverheidCert"),
			subjectKeyIdentifier: Data("Wrong".utf8)
		)
		sut = CMSSignatureValidator(trustedSigners: [signingCertificate])
		
		// When
		let result = sut.validate(
			signature: try getbase64EncodedData("pkcs1Signature"),
			content: try getbase64EncodedData("pkcs1Payload") + Data("Wrong".utf8)
		)
		
		// Then
		expect(result) == false
	}
	
	func test_validSignature_validSigner_wrongSerial() throws {
		
		// Given
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use sigh.sh to generate the pkcs1 signature
		// Use cleanup.sh to remove the unneeded files
		let signingCertificate = SigningCertificate(
			name: "certFakePKIOverheid",
			certificate: try getCertificateString("fakePKIOverheidCert"),
			rootSerial: 10000013
		)
		sut = CMSSignatureValidator(trustedSigners: [signingCertificate])
		
		// When
		let result = sut.validate(
			signature: try getbase64EncodedData("pkcs1Signature"),
			content: try getbase64EncodedData("pkcs1Payload") + Data("Wrong".utf8)
		)
		
		// Then
		expect(result) == false
	}
}
