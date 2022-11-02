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
	///   - issuerConfiguration: openID configuration
	///   - presentingViewController: an optional view controller that presents the authentication view
	///   - openIDConnectState: the state of the current connection
	///   - onCompletion: completion handler with the access token
	///   - onError: the error handler
	func requestAccessToken(
		issuerConfiguration: OpenIDConnectConfiguration,
		presentingViewController: UIViewController?,
		openIDConnectState: OpenIDConnectState?,
		onCompletion: @escaping (OpenIDConnectToken) -> Void,
		onError: @escaping (Error?) -> Void)
}
