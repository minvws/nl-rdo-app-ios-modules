/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public protocol SignatureValidation {
	
	/// Validate a signature
	/// - Parameters:
	///   - signature: the signature to validate
	///   - content: the signed content
	/// - Returns: True if the signature is a valid signature
	func validate(signature: Data, content: Data) -> Bool
}

public extension SignatureValidation {
	
	/// Validate a signature
	/// - Parameters:
	///   - data: the signed content
	///   - signature: the signature
	///   - completion: Completion handler
	func validate(data: Data, signature: Data, completion: @escaping (Bool) -> Void) {
		DispatchQueue.global().async {
			let result = validate(signature: signature, content: data)
			
			DispatchQueue.main.async {
				completion(result)
			}
		}
	}
}
