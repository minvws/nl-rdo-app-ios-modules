/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import HTTPSecurityObjC
import Logging

/// Security check for backend communication
public class CMSSignatureValidator: SignatureValidation {
	
	private var trustedSigners: [SigningCertificate]
	private let x509Validator = X509Validator()
	
	public init(trustedSigners: [SigningCertificate] = []) {
		
		self.trustedSigners = trustedSigners
	}
	
	/// Validate a CMS signature
	/// - Parameters:
	///   - signature: the signature to validate
	///   - content: the signed content
	/// - Returns: True if the signature is a valid CMS Signature
	///   See: https://en.wikipedia.org/wiki/Cryptographic_Message_Syntax
	public func validate(signature: Data, content: Data) -> Bool {
		
		for signer in trustedSigners {
			
			let certificateData = signer.getCertificateData()
			
			if let subjectKeyIdentifier = signer.subjectKeyIdentifier,
			   !x509Validator.validateSubjectKeyIdentifier(subjectKeyIdentifier, forCertificateData: certificateData) {
				logError("CMSSignatureValidator - validateSubjectKeyIdentifier(subjectKeyIdentifier) failed")
				return false
			}
			
			if let serial = signer.rootSerial,
			   !x509Validator.validateSerialNumber( serial, forCertificateData: certificateData) {
				logError("CMSSignatureValidator - validateSerialNumber(serial) is invalid")
				return false
			}
			
			if x509Validator.validateCMSSignature(
				signature,
				contentData: content,
				certificateData: certificateData,
				authorityKeyIdentifier: signer.authorityKeyIdentifier,
				requiredCommonNameContent: signer.commonName ?? "") {
				return true
			}
		}
		return false
	}
}
