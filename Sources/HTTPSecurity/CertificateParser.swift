/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import HTTPSecurityObjC

public class CertificateParser {
	
	private let x509Validator = X509Validator()
	
	/// Initializer
	public init() {}
	
	/// Get the Authority Key Identifier from a X509 Certificiate
	/// - Parameter certificate: the X509 Certificate
	/// - Returns: optional Authority Key Identifier
	public func getAuthorityKeyIdentifier(for certificate: Data) -> Data? {
		
		return x509Validator.getAuthorityKeyIdentifier(forCertificate: certificate)
	}
	
	/// Get the common name from a X509 Certificiate
	/// - Parameter certificate: the X509 Certificiate
	/// - Returns: optional Common Name
	public func getCommonName(for certificate: Data) -> String? {
		
		return x509Validator.getCommonName(forCertificate: certificate)
	}
	
	/// Get the Subject Alternative Names from a X509 Certificiate
	/// - Parameter certificateData: the X509 Certificate
	/// - Returns: an optional array of Subject Alternative Names
	public func getSubjectAlternativeDNSNames(for certificateData: Data) -> [String]? {
		
		return x509Validator.getSubjectAlternativeDNSNames(certificateData) as? [String]
	}
}
