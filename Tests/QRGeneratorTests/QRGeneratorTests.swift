/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import QRGenerator

class QRGeneratorTests: XCTestCase {

	func test_generate_fromData() throws {
		
		// Given
		let message = "This is a test"
		let data = try XCTUnwrap(message.data(using: .utf8))
		
		// When
		let image = data.generateQRCode(correctionLevel: CorrectionLevel.medium)
		
		// Then
		XCTAssertNotNil(image)
	}
	
	func test_generate_fromString() {
		
		// Given
		let message = "This is a test"
		
		// When
		let image = message.generateQRCode(correctionLevel: CorrectionLevel.medium)
		
		// Then
		XCTAssertNotNil(image)
	}
}
