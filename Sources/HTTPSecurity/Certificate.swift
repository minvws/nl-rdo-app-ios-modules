/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import Security

public struct Certificate {

	private let secCertificate: SecCertificate
	
	public init(certificate: SecCertificate) {
		self.secCertificate = certificate
	}

	public var data: Data {

		let data = SecCertificateCopyData(secCertificate) as Data
		let base64String = data.base64EncodedString()
		let fullString = "-----BEGIN CERTIFICATE-----\n\(base64String)\n-----END CERTIFICATE-----"
		return Data(fullString.utf8)
	}

	public var commonName: String? {

		var name: CFString?
		let status = SecCertificateCopyCommonName(secCertificate, &name)

		if status == OSStatus.zero, let name = name {
			return name as String
		}
		return nil
	}
}
