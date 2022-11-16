/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import HTTPSecurityObjC

public class CMSCertificateHelper {
	
	let x509Validator = X509Validator()
	
	public init() {}
	
	public func getCommonName(for certificate: Data) -> String? {
		return x509Validator.getCommonName(forCertificate: certificate)
	}
	
	public func getAuthorityKeyIdentifier(for certificate: Data) -> Data? {
		return x509Validator.getAuthorityKeyIdentifier(forCertificate: certificate)
	}
}
