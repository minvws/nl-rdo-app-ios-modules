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
	
//	func test_validateCMSSignature_padding_pkcs_validPayload() throws {
//
//		// Given
//		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
//		let certificateData = try Data(contentsOf: certificateUrl)
//
//		// When
//		let validation = sut.validateCMSSignature(
//			ValidationData.signaturePKCS,
//			contentData: ValidationData.payload,
//			certificateData: certificateData,
//			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
//			requiredCommonNameContent: ".coronatester.nl"
//		)
//
//		// Then
//		expect(validation) == true
//	}
//
//	func test_validateCMSSignature__padding_pkcs_wrongPayload() throws {
//
//		// Given
//		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
//		let certificateData = try Data(contentsOf: certificateUrl)
//
//		// When
//		let validation = sut.validateCMSSignature(
//			ValidationData.signaturePKCS,
//			contentData: ValidationData.wrongPayload,
//			certificateData: certificateData,
//			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
//			requiredCommonNameContent: ".coronatester.nl"
//		)
//
//		// Then
//		expect(validation) == false
//	}
//
//	func test_validateCMSSignature__padding_pss_validPayload() throws {
//
//		// Given
//		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
//		let certificateData = try Data(contentsOf: certificateUrl)
//
//		// When
//		let validation = sut.validateCMSSignature(
//			ValidationData.signaturePSS,
//			contentData: ValidationData.payload,
//			certificateData: certificateData,
//			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
//			requiredCommonNameContent: ".coronatester.nl"
//		)
//
//		// Then
//		expect(validation) == true
//	}
//
//	func test_validateCMSSignature__padding_pss_wrongPayload() throws {
//
//		// Given
//		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
//		let certificateData = try Data(contentsOf: certificateUrl)
//
//		// When
//		let validation = sut.validateCMSSignature(
//			ValidationData.wrongPayload,
//			contentData: ValidationData.payload,
//			certificateData: certificateData,
//			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
//			requiredCommonNameContent: ".coronatester.nl"
//		)
//
//		// Then
//		expect(validation) == false
//	}
//
//	func test_validateCMSSignature__test_pinning_wrongCommonName() throws {
//
//		// Given
//		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
//		let certificateData = try Data(contentsOf: certificateUrl)
//
//		// When
//		let validation = sut.validateCMSSignature(
//			ValidationData.signaturePKCS,
//			contentData: ValidationData.payload,
//			certificateData: certificateData,
//			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
//			requiredCommonNameContent: ".coronacheck.nl"
//		)
//
//		// Then
//		expect(validation) == false
//	}
//
//	func test_validateCMSSignature__test_pinning_commonNameAsPartOfDomain() throws {
//
//		// Given
//		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
//		let certificateData = try Data(contentsOf: certificateUrl)
//
//		// When
//		let validation = sut.validateCMSSignature(
//			ValidationData.signaturePKCS,
//			contentData: ValidationData.payload,
//			certificateData: certificateData,
//			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
//			requiredCommonNameContent: ".coronatester.nl.xx.nl"
//		)
//
//		// Then
//		expect(validation) == false
//	}
//
//	func test_validateCMSSignature__test_pinning_emptyCommonName() throws {
//
//		// Given
//		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
//		let certificateData = try Data(contentsOf: certificateUrl)
//
//		// When
//		let validation = sut.validateCMSSignature(
//			ValidationData.signaturePKCS,
//			contentData: ValidationData.payload,
//			certificateData: certificateData,
//			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
//			requiredCommonNameContent: ""
//		)
//
//		// Then
//		expect(validation) == true
//	}
//
//	func test_validateCMSSignature__test_pinning_emptyAuthorityKeyIdentifier() throws {
//
//		// Given
//		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
//		let certificateData = try Data(contentsOf: certificateUrl)
//
//		// When
//		let validation = sut.validateCMSSignature(
//			ValidationData.signaturePKCS,
//			contentData: ValidationData.payload,
//			certificateData: certificateData,
//			authorityKeyIdentifier: nil,
//			requiredCommonNameContent: "coronatester.nl"
//		)
//
//		// Then
//		expect(validation) == true
//	}
//
//	func test_validateCMSSignature__test_pinning_emptyAuthorityKeyIdentifier_emptyCommonName() throws {
//
//		// Given
//		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certFakePKIOverheid", withExtension: ".pem"))
//		let certificateData = try Data(contentsOf: certificateUrl)
//
//		// When
//		let validation = sut.validateCMSSignature(
//			ValidationData.signaturePKCS,
//			contentData: ValidationData.payload,
//			certificateData: certificateData,
//			authorityKeyIdentifier: nil,
//			requiredCommonNameContent: ""
//		)
//
//		// Then
//		expect(validation) == true
//	}
//
	func test_validateCMSSignature_verydeep() throws {
		
		// Use deep-chain.sh to generate this certificate
		
		// Given
		
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
		
		// Use deep-chain.sh to generate this certificate
		
		// Given
		
		// When
		let validation = sut.validateCMSSignature(
			try getbase64EncodedData("deepSignature"),
			contentData: try getbase64EncodedData("deepPayload"),
			certificateData: try getCertificateData("deepChainCert"),
			authorityKeyIdentifier: ValidationData.authorityKeyIdentifier,
			requiredCommonNameContent: "leaf"
		)
		
		// Then
		expect(validation) == false
	}
//
//	func test_validateCMSSignature_noCommonName() throws {
//
//		// Use long-chain.sh to generate this certificate
//
//		// Given
//		let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: "certWithoutCN", withExtension: ".pem"))
//		let certificateData = try Data(contentsOf: certificateUrl)
//
//		// When
//		let validation = sut.validateCMSSignature(
//			ValidationData.signatureNoCommonName,
//			contentData: ValidationData.payload,
//			certificateData: certificateData,
//			authorityKeyIdentifier: ValidationData.noCommonNameAuthorityKeyIdentifier,
//			requiredCommonNameContent: ".coronatester..nl"
//		)
//
//		// Then
//		expect(validation) == false
//	}
}

func getCertificateData(_ fileName: String, extention: String = ".pem") throws -> Data {
	
	let certificateUrl = try XCTUnwrap(Bundle.module.url(forResource: fileName, withExtension: extention))
	let certificateData = try Data(contentsOf: certificateUrl)
	return certificateData
}

func getAuthorityKeyIdentifierData(_ fileName: String, extention: String = ".txt") throws -> Data {

	let url = try XCTUnwrap(Bundle.module.url(forResource: fileName, withExtension: extention))
	let content = try String(contentsOf: url).trimmingCharacters(in: .whitespacesAndNewlines)
	var result = Data()
	content.components(separatedBy: ",").forEach { element in
		print("element: \(element)")
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

	 func data(using encoding:ExtendedEncoding) -> Data? {
		 let hexStr = self.dropFirst(self.hasPrefix("0x") ? 2 : 0)

		 guard hexStr.count % 2 == 0 else { return nil }

		 var newData = Data(capacity: hexStr.count/2)

		 var indexIsEven = true
		 for i in hexStr.indices {
			 if indexIsEven {
				 let byteRange = i...hexStr.index(after: i)
				 guard let byte = UInt8(hexStr[byteRange], radix: 16) else { return nil }
				 newData.append(byte)
			 }
			 indexIsEven.toggle()
		 }
		 return newData
	 }
 }
