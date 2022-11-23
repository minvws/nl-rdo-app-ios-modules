/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

/// Allow every signature.  Used for testing.
public class AlwaysAllowSignatureValidator: SignatureValidation {
	
	public init() {}
	
	/// Validate a signature
	/// - Parameters:
	///   - signature: the signature to validate
	///   - content: the signed content
	/// - Returns: Always true
	public func validate(signature: Data, content: Data) -> Bool {
		
		return true
	}
}
