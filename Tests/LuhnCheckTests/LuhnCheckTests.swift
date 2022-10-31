/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import LuhnCheck

class LuhnCheckTests: XCTestCase {

	private var sut: LuhnCheck!

	override func setUp() {

		super.setUp()

		sut = LuhnCheck()
	}

	func test_luhnNChecksum_withValidTokens() {

		// Given
		let validTokens: [String] = [
			"2SX4XLGGXUB6V94",
			"YL8BSX9T6J39C7Q",
			"2FR36XSUGJY3UZG",
			"32X4RUBC2TYBX6U",
			"SGF25J4TBTX",
			"4RRT5FRQ6LX",
			"QGJ6Y2SBSY6"
		]

		for token in validTokens {

			// When
			let result = sut.luhnModN(token)

			// Then
			XCTAssertTrue(result)
		}
	}

	func test_luhnNChecksum_withInvalidTokens() {

		// Given
		let invalidTokens: [String] = [
			"2SX4XLGGXUB6V84",
			"YL8BSX9T6J39C7L",
			"SGF25J4TBTY"
		]

		for token in invalidTokens {

			// When
			let result = sut.luhnModN(token)

			// Then
			XCTAssertFalse(result)
		}
	}

	func test_luhnNChecksum_withInvalidChars() {

		// Given
		let invalidCharTokens: [String] = [
			"2SPW782",
			"SGF25J4TBTA"
		]

		for token in invalidCharTokens {

			// When
			let result = sut.luhnModN(token)

			// Then
			XCTAssertFalse(result)
		}
	}
}
