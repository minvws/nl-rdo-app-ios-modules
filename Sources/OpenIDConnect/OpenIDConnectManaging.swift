/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import AppAuth

public protocol OpenIDConnectManaging: AnyObject {
	
	/// Request an access token
	/// - Parameters:
	///   - configuration: openID configuration
	///   - onCompletion: ompletion handler with optional access token
	///   - onError: error handler
	func requestAccessToken(
		issuerConfiguration: OpenIDConnectConfiguration,
		presentingViewController: UIViewController?,
		onCompletion: @escaping (OpenIDConnectToken) -> Void,
		onError: @escaping (Error?) -> Void)
}
