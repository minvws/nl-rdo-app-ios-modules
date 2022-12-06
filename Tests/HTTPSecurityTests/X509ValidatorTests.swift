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
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use sigh.sh to generate the pkcs1 signature
		// Use sigh_pss.sh to generate the pss signature
		// Use cleanup.sh to remove the unneeded files

		// When
		let validation = sut.validateCMSSignature(
			try getbase64EncodedData("pkcs1Signature"),
			contentData: try getbase64EncodedData("pkcs1Payload"),
			certificateData: try getCertificateData("fakePKIOverheidCert"),
			authorityKeyIdentifier: try getAuthorityKeyIdentifierData("authorityKeyIdentifier"),
			requiredCommonNameContent: ".rdobeheer.nl"
		)

		// Then
		expect(validation) == true
	}

	func test_validateCMSSignature_padding_pkcs_wrongPayload() throws {

		// Given
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use sigh.sh to generate the pkcs1 signature
		// Use sigh_pss.sh to generate the pss signature
		// Use cleanup.sh to remove the unneeded files

		// When
		let validation = sut.validateCMSSignature(
			try getbase64EncodedData("pkcs1Signature"),
			contentData: try getbase64EncodedData("pkcs1Payload") + Data("Wrong".utf8),
			certificateData: try getCertificateData("fakePKIOverheidCert"),
			authorityKeyIdentifier: try getAuthorityKeyIdentifierData("authorityKeyIdentifier"),
			requiredCommonNameContent: ".rdobeheer.nl"
		)

		// Then
		expect(validation) == false
	}

	func test_validateCMSSignature_padding_pss_validPayload() throws {

		// Given
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use sigh.sh to generate the pkcs1 signature
		// Use sigh_pss.sh to generate the pss signature
		// Use cleanup.sh to remove the unneeded files

		// When
		let validation = sut.validateCMSSignature(
			try getbase64EncodedData("pssSignature"),
			contentData: try getbase64EncodedData("pssPayload"),
			certificateData: try getCertificateData("fakePKIOverheidCert"),
			authorityKeyIdentifier: try getAuthorityKeyIdentifierData("authorityKeyIdentifier"),
			requiredCommonNameContent: ".rdobeheer.nl"
		)

		// Then
		expect(validation) == true
	}

	func test_validateCMSSignature_padding_pss_wrongPayload() throws {

		// Given
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use sigh.sh to generate the pkcs1 signature
		// Use sigh_pss.sh to generate the pss signature
		// Use cleanup.sh to remove the unneeded files

		// When
		let validation = sut.validateCMSSignature(
			try getbase64EncodedData("pssSignature"),
			contentData: try getbase64EncodedData("pssPayload") + Data("Wrong".utf8),
			certificateData: try getCertificateData("fakePKIOverheidCert"),
			authorityKeyIdentifier: try getAuthorityKeyIdentifierData("authorityKeyIdentifier"),
			requiredCommonNameContent: ".rdobeheer.nl"
		)

		// Then
		expect(validation) == false
	}

	func test_validateCMSSignature_test_pinning_wrongCommonName() throws {

		// Given
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use sigh.sh to generate the pkcs1 signature
		// Use sigh_pss.sh to generate the pss signature
		// Use cleanup.sh to remove the unneeded files

		// When
		let validation = sut.validateCMSSignature(
			try getbase64EncodedData("pkcs1Signature"),
			contentData: try getbase64EncodedData("pkcs1Payload"),
			certificateData: try getCertificateData("fakePKIOverheidCert"),
			authorityKeyIdentifier: try getAuthorityKeyIdentifierData("authorityKeyIdentifier"),
			requiredCommonNameContent: ".coronacheck.nl"
		)

		// Then
		expect(validation) == false
	}

	func test_validateCMSSignature_test_pinning_commonNameAsPartOfDomain() throws {

		// Given
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use sigh.sh to generate the pkcs1 signature
		// Use sigh_pss.sh to generate the pss signature
		// Use cleanup.sh to remove the unneeded files

		// When
		let validation = sut.validateCMSSignature(
			try getbase64EncodedData("pkcs1Signature"),
			contentData: try getbase64EncodedData("pkcs1Payload"),
			certificateData: try getCertificateData("fakePKIOverheidCert"),
			authorityKeyIdentifier: try getAuthorityKeyIdentifierData("authorityKeyIdentifier"),
			requiredCommonNameContent: ".rdobeheer.nl.malicioushacker.nl"
		)

		// Then
		expect(validation) == false
	}

	func test_validateCMSSignature_test_pinning_emptyCommonName() throws {

		// Given
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use sigh.sh to generate the pkcs1 signature
		// Use sigh_pss.sh to generate the pss signature
		// Use cleanup.sh to remove the unneeded files

		// When
		let validation = sut.validateCMSSignature(
			try getbase64EncodedData("pkcs1Signature"),
			contentData: try getbase64EncodedData("pkcs1Payload"),
			certificateData: try getCertificateData("fakePKIOverheidCert"),
			authorityKeyIdentifier: try getAuthorityKeyIdentifierData("authorityKeyIdentifier"),
			requiredCommonNameContent: ""
		)

		// Then
		expect(validation) == true
	}

	func test_validateCMSSignature_test_pinning_emptyAuthorityKeyIdentifier() throws {

		// Given
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use sigh.sh to generate the pkcs1 signature
		// Use sigh_pss.sh to generate the pss signature
		// Use cleanup.sh to remove the unneeded files

		// When
		let validation = sut.validateCMSSignature(
			try getbase64EncodedData("pkcs1Signature"),
			contentData: try getbase64EncodedData("pkcs1Payload"),
			certificateData: try getCertificateData("fakePKIOverheidCert"),
			authorityKeyIdentifier: nil,
			requiredCommonNameContent: ".rdobeheer.nl"
		)

		// Then
		expect(validation) == true
	}

	func test_validateCMSSignature_test_pinning_emptyAuthorityKeyIdentifier_emptyCommonName() throws {

		// Given
		// Use fakeStaatDerNederlanden.sh to generate this certificate
		// Use sigh.sh to generate the pkcs1 signature
		// Use sigh_pss.sh to generate the pss signature
		// Use cleanup.sh to remove the unneeded files

		// When
		let validation = sut.validateCMSSignature(
			try getbase64EncodedData("pkcs1Signature"),
			contentData: try getbase64EncodedData("pkcs1Payload"),
			certificateData: try getCertificateData("fakePKIOverheidCert"),
			authorityKeyIdentifier: nil,
			requiredCommonNameContent: ""
		)

		// Then
		expect(validation) == true
	}

	func test_validateCMSSignature_verydeep() throws {
		
		// Given
		// Use deepChain.sh to generate this certificate
		
		// When
		let validation = sut.validateCMSSignature(
			try getbase64EncodedData("deepSignature"),
			contentData: try getbase64EncodedData("deepPayload"),
			certificateData: try getCertificateData("deepChainCert"),
			authorityKeyIdentifier: try getAuthorityKeyIdentifierData("deepAuthorityKeyIdentifier"),
			requiredCommonNameContent: "leaf"
		)
		
		// Then
		expect(validation) == true
	}
	
	func test_validateCMSSignature_verydeep_invalidAuthorityKeyIdentifier() throws {
		
		// Given
		// Use deepChain.sh to generate this certificate
		
		// When
		let validation = sut.validateCMSSignature(
			try getbase64EncodedData("deepSignature"),
			contentData: try getbase64EncodedData("deepPayload"),
			certificateData: try getCertificateData("deepChainCert"),
			authorityKeyIdentifier: try getAuthorityKeyIdentifierData("authorityKeyIdentifier"),
			requiredCommonNameContent: "leaf"
		)
		
		// Then
		expect(validation) == false
	}

	func test_validateCMSSignature_noCommonName() throws {

		// Given
		// Use noCommonName.sh to generate this certificate

		// When
		let validation = sut.validateCMSSignature(
			try getbase64EncodedData("noCommonNameSignature"),
			contentData: try getbase64EncodedData("noCommonNamePayload"),
			certificateData: try getCertificateData("noCommonNameCert"),
			authorityKeyIdentifier: try getAuthorityKeyIdentifierData("noCommonNameAuthorityKeyIdentifier"),
			requiredCommonNameContent: ".rdobeheer.nl"
		)

		// Then
		expect(validation) == false
	}
	
	func test_validateCMSSignature_noCommonName_noRequiredName() throws {

		// Given
		// Use noCommonName.sh to generate this certificate

		// When
		let validation = sut.validateCMSSignature(
			try getbase64EncodedData("noCommonNameSignature"),
			contentData: try getbase64EncodedData("noCommonNamePayload"),
			certificateData: try getCertificateData("noCommonNameCert"),
			authorityKeyIdentifier: try getAuthorityKeyIdentifierData("noCommonNameAuthorityKeyIdentifier"),
			requiredCommonNameContent: ""
		)

		// Then
		expect(validation) == true
	}
}

func getCertificateData(_ fileName: String, extention: String = ".pem") throws -> Data {
	
	let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: fileName, withExtension: extention))
	let content = try Data(contentsOf: certificateUrl)
	return content
}

func getCertificateString(_ fileName: String, extention: String = ".pem") throws -> String {
	
	let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: fileName, withExtension: extention))
	let content = try String(contentsOf: certificateUrl)
	return content
}

func getAuthorityKeyIdentifierData(_ fileName: String, extention: String = ".txt") throws -> Data {

	let url = try XCTUnwrap(Bundle.module.url(forResource: fileName, withExtension: extention))
	let content = try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines)
	var result = Data()
	content.components(separatedBy: ",").forEach { element in
		if let hexData = element.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .hexadecimal) {
			result.append(hexData)
		}
	}
	return result
}

func getbase64EncodedData(_ fileName: String, extention: String = ".txt") throws -> Data {
	
	let url = try XCTUnwrap(Bundle.module.url(forResource: fileName, withExtension: extention))
	let content = try String(contentsOf: url).trimmingCharacters(in: .newlines)
	let base64 = try XCTUnwrap(Data(base64Encoded: content))
	return base64
}

extension String {
	 enum ExtendedEncoding {
		 case hexadecimal
	 }

	 func data(using encoding: ExtendedEncoding) -> Data? {
		 let hexStr = self.dropFirst(self.hasPrefix("0x") ? 2 : 0)

		 guard hexStr.count % 2 == 0 else { return nil }

		 var newData = Data(capacity: hexStr.count / 2)

		 var indexIsEven = true
		 for index in hexStr.indices {
			 if indexIsEven {
				 let byteRange = index...hexStr.index(after: index)
				 guard let byte = UInt8(hexStr[byteRange], radix: 16) else { return nil }
				 newData.append(byte)
			 }
			 indexIsEven.toggle()
		 }
		 return newData
	 }
 }
