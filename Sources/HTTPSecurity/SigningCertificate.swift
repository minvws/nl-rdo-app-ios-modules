/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

public struct SigningCertificate {

	/// The name of the certificate
	public let name: String

	/// The certificate
	public let certificate: String

	/// The required common name
	public var commonName: String?

	/// The required authority Key
	public var authorityKeyIdentifier: Data?

	/// The required subject key
	public let subjectKeyIdentifier: Data?

	/// The serial number
	public let rootSerial: UInt64?
	
	public init(name: String, certificate: String, commonName: String? = nil, authorityKeyIdentifier: Data? = nil, subjectKeyIdentifier: Data? = nil, rootSerial: UInt64? = nil) {
		self.name = name
		self.certificate = certificate
		self.commonName = commonName
		self.authorityKeyIdentifier = authorityKeyIdentifier
		self.subjectKeyIdentifier = subjectKeyIdentifier
		self.rootSerial = rootSerial
	}

	/// Get the certificate data
	/// - Returns: the certificate data
	public func getCertificateData() -> Data {

		return Data(certificate.utf8)
	}
}
