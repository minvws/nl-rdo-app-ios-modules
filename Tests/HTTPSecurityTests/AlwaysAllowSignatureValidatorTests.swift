/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import HTTPSecurity

class AlwaysAllowSignatureValidatorTests: XCTestCase {
	
	private var sut: AlwaysAllowSignatureValidator!
	
	override func setUp() {
		
		super.setUp()
		sut = AlwaysAllowSignatureValidator()
	}
	
	func test_validSignature() throws {
		
		// Given
		
		// When
		let result = sut.validate(
			signature: try getbase64EncodedData("pkcs1Signature"),
			content: try getbase64EncodedData("pkcs1Payload")
		)
		
		// Then
		expect(result) == true
	}
	
	func test_invalidSignature() throws {
		
		// Given
		
		// When
		let result = sut.validate(
			signature: try getbase64EncodedData("pkcs1Signature"),
			content: try getbase64EncodedData("pkcs1Payload") + Data("Wrong".utf8)
		)
		
		// Then
		expect(result) == true
	}
}
