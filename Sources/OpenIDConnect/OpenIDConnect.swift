/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@_exported import AppAuth

public extension Notification.Name {
	
	static let launchingOpenIDConnectBrowser = Notification.Name("nl.rijksoverheid.rdo.launchingOpenIDConnectBrowser")
	static let closingOpenIDConnectBrowser = Notification.Name("nl.rijksoverheid.rdo.closingOpenIDConnectBrowser")
}
