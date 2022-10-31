/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import AppAuth

public protocol OpenIDConnectConfiguration: AnyObject {
	
	var issuerUrl: URL { get }

	var clientId: String { get }

	var redirectUri: URL { get }
}
