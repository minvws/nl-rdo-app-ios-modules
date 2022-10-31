/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import AppAuth

public protocol OpenIDConnectToken {
	
	var idToken: String? { get }
	var accessToken: String? { get }
}

extension OIDTokenResponse: OpenIDConnectToken {
	
}
