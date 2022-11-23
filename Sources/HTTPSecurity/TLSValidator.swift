/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import HTTPSecurityObjC

public class TLSValidator {
	
	let x509Validator = X509Validator()
	
	public init() {}
	
	public func validateSubjectAlternativeDNSName(_ hostname: String, for certificateData: Data) -> Bool {
		
		return x509Validator.validateSubjectAlternativeDNSName(hostname, forCertificateData: certificateData)
	}
	
	public func compare(_ certificateData: Data, with trustedCertificate: Data) -> Bool {
		
		return x509Validator.compare(certificateData, withTrustedCertificate: trustedCertificate)
	}
}
