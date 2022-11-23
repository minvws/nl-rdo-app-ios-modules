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
	
	func test_validSignature() {
		
		// Given
		
		// When
		let result = sut.validate(signature: ValidationData.signaturePKCS, content: ValidationData.payload)
		
		// Then
		expect(result) == true
	}
	
	func test_invalidSignature() {
		
		// Given
		
		// When
		let result = sut.validate(signature: ValidationData.signaturePKCS, content: ValidationData.wrongPayload)
		
		// Then
		expect(result) == true
	}
	
}
