/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import HTTPSecurity
@testable import HTTPSecurityObjC
import XCTest
import Nimble

class AppTransportSecurityCheckerTests: XCTestCase {
	
	private var sut: AppTransportSecurityChecker!
	private let policy = SecPolicyCreateSSL(true, "roolproductions.com" as CFString)
	
	// Real certificates
	
	private var realLeaf: Data!
	private var realLeafCert: SecCertificate!

	private var realRoot: Data!
	private var realCross: Data!
	private var realChain01: Data!
	private var realChain02: Data!
	private var realChain: [Data]!

	private var realChainCertArray = [SecCertificate]()
	
	// Fake certificates (where fake means we pretended to be the Certificate Authority and resigned everything)
	
	private var fakeLeaf: Data!
	private var fakeLeafCert: SecCertificate!
	
	private var fakeRoot: Data!
	private var fakeChain01: Data!
	private var fakeChain02: Data!
	private var fakeChain: [Data]!

	private var fakeChainCertArray = [SecCertificate]()
	
	override func setUpWithError() throws {
		
		try super.setUpWithError()
		sut = AppTransportSecurityChecker()
		
		try setupRealCertificates()
		try setupFakeCertificates()
	}
	
	private func setupRealCertificates() throws {
		
		// Use `perl generateATSCertificates.pl` to fetch the original real certificates and resign them.
	
		// use www.roolproductions.com
		realLeaf = try getCertificateData("rool")
		
		// https://letsencrypt.org/certs/isrg-root-x1-cross-signed.pem
		realChain01 = try getCertificateData("isrg-root-x1-cross-signed")
		
		// https://letsencrypt.org/certs/lets-encrypt-r3.pem (Signed by ISRG Root X1)
		realChain02 = try getCertificateData("lets-encrypt-r3")
		
		// https://letsencrypt.org/certs/isrg-root-x2-cross-signed.pem
		realCross = try getCertificateData("isrg-root-x2-cross-signed")
		
		// https://letsencrypt.org/certs/trustid-x3-root.pem.txt (Expired Sep 30 2021)
		realRoot = try getCertificateData("dst-root-ca-xs")
		
		realChain = [realCross, realChain01, realChain02]
		
		for certPem in realChain {
			let cert = sut.certificateFromPEM(certificateAsPemData: certPem)
			expect(cert) != nil
			realChainCertArray.append(cert!)
		}
		realLeafCert = sut.certificateFromPEM(certificateAsPemData: realLeaf)
	}
	
	private func setupFakeCertificates() throws {
		
		// Use `perl generateATSCertificates.pl` to fetch the original real certificates and resign them.
	
		fakeChain01 = try getCertificateData("isrg-root-x1-cross-signed", extention: ".fake")
		fakeChain02 = try getCertificateData("lets-encrypt-r3", extention: ".fake")
		fakeLeaf = try getCertificateData("rool", extention: ".fake")
		fakeRoot = try getCertificateData("dst-root-ca-xs", extention: ".fake")
		
		fakeChain = [fakeChain02, fakeChain01]
		
		fakeLeafCert = sut.certificateFromPEM(certificateAsPemData: fakeLeaf)
		XCTAssert(fakeLeafCert != nil)
		
		fakeChainCertArray = [SecCertificate]()
		for certPem in fakeChain {
			let cert = sut.certificateFromPEM(certificateAsPemData: certPem)
			XCTAssert(cert != nil)
			fakeChainCertArray.append(cert!)
		}
		
	}
	
	// MARK: - TESTS -
	
	// MARK: - Real Server Trust, Real Leaf
	
	private var realServerTrust: SecTrust? {
		
		var optionalTrust: SecTrust?
		
		// the first certifcate is the one to check - the rest is to aid validation.
		XCTAssert(noErr == SecTrustCreateWithCertificates([ realLeafCert ] + realChainCertArray as CFArray,
														  policy,
														  &optionalTrust))
		XCTAssertNotNil(optionalTrust)
		return optionalTrust
	}
	
	func test_realServerTrust_noTrustedCertificates_realLeaf() throws {
		
		// This should success - as we rely on the build in well known root.
		
		// Given
		let serverTrust = try XCTUnwrap(realServerTrust)
		
		// When
		let result = sut.check(
			serverTrust: serverTrust,
			policies: [policy],
			trustedCertificates: [])
		
		// Then
		expect(result) == true
	}
	
	func test_realServerTrust_expiredRoot_realLeaf() throws {
		
		// This should fail - as we explictly rely on the root which is expired
		
		// Given
		let serverTrust = try XCTUnwrap(realServerTrust)
		
		// When
		let result = sut.check(
			serverTrust: serverTrust,
			policies: [policy],
			trustedCertificates: [realRoot])
		
		// Then
		expect(result) == false
	}
	
	func test_realServerTrust_trustedChain_realLeaf() throws {
		
		// This should succeed - as we explictly rely on the chain.
		
		// Given
		let serverTrust = try XCTUnwrap(realServerTrust)
		
		// When
		let result = sut.check(
			serverTrust: serverTrust,
			policies: [policy],
			trustedCertificates: [realChain01])
		
		// Then
		expect(result) == true
	}
	
	func test_realServerTrust_fakeRoot_realLeaf() throws {
		
		// This should fail - as we are giving it the wrong root.
		
		// Given
		let serverTrust = try XCTUnwrap(realServerTrust)
		
		// When
		let result = sut.check(
			serverTrust: serverTrust,
			policies: [policy],
			trustedCertificates: [fakeRoot])
		
		// Then
		expect(result) == false
	}
	
	// MARK: - Fake Server Trust, Fake Leaf
	
	private var fakeServerTrust: SecTrust? {
		
		var optionalTrust: SecTrust?
		
		// the first certifcate is the one to check - the rest is to aid validation.
		XCTAssert(noErr == SecTrustCreateWithCertificates([ fakeLeafCert ] + fakeChainCertArray as CFArray,
														  policy,
														  &optionalTrust))
		XCTAssertNotNil(optionalTrust)
		return optionalTrust
	}
	
	func test_fakeServerTrust_noTrustedCertificates_fakeLeaf() throws {
		
		// This should fail - as the root is not build in. It may however
		// succeed if the user has somehow the fake root into the system trust
		// chain -and- set it to 'trusted' (or was fooled/hacked into that).
		//
		// In theory this requires:
		// 1) creating the DER version of the fake CA.
		//     openssl x509 -in ca.pem -out fake.crt -outform DER
		// 2) Loading this into the emulator via Safari
		// 3) Hitting install in Settings->General->Profiles
		// 4) Enabling it as trusted in Settings->About->Certificate Trust settings.
		// but we've not gotten this to work reliably yet (just once).
		
		// Given
		let serverTrust = try XCTUnwrap(fakeServerTrust)
		
		// When
		let result = sut.check(
			serverTrust: serverTrust,
			policies: [policy],
			trustedCertificates: [])
		
		// Then
		expect(result) == false
	}
	
	func test_fakeServerTrust_fakeRoot_fakeLeaf() throws {
		
		// This should succeed - as we are giving it the right root to trust.
		
		// Given
		let serverTrust = try XCTUnwrap(fakeServerTrust)
		
		// When
		let result = sut.check(
			serverTrust: serverTrust,
			policies: [policy],
			trustedCertificates: [fakeRoot])
		
		// Then
		expect(result) == true
	}
	
	func test_fakeServerTrust_realRoot_fakeLeaf() throws {
		
		// This should fail - as we are giving it the wrong root to trust.
		
		// Given
		let serverTrust = try XCTUnwrap(fakeServerTrust)
		
		// When
		let result = sut.check(
			serverTrust: serverTrust,
			policies: [policy],
			trustedCertificates: [realRoot])
		
		// Then
		expect(result) == false
	}
	
	// MARK: Worst case scenario.
	
	private var kitchenSinkServerTrust: SecTrust? {
		
		// Create a 'worst case' kitchen sink chain with as much in it as we can think off.
		let realRootCert = sut.certificateFromPEM(certificateAsPemData: realRoot)
		let fakeRootCert = sut.certificateFromPEM(certificateAsPemData: fakeRoot)
		let allChainCerts = realChainCertArray + fakeChainCertArray + [ realRootCert, fakeRootCert]
		
		var optionalTrust: SecTrust?
		
		// the first certifcate is the one to check - the rest is to aid validation.
		XCTAssert(noErr == SecTrustCreateWithCertificates([ fakeLeafCert ] + allChainCerts as CFArray,
														  policy,
														  &optionalTrust))
		XCTAssertNotNil(optionalTrust)
		return optionalTrust
	}
	
	func test_kitchenSinkServerTrust_noTrustedCertificates_fakeLeaf() throws {
		
		// This should fail - as the root is not build in. It may however
		// succeed if the user has somehow the fake root into the system trust
		// chain -and- set it to 'trusted' (or was fooled/hacked into that).
		
		// Given
		let serverTrust = try XCTUnwrap(kitchenSinkServerTrust)
		
		// When
		let result = sut.check(
			serverTrust: serverTrust,
			policies: [policy],
			trustedCertificates: [])
		
		// Then
		expect(result) == false
	}

	func test_kitchenSinkServerTrust_fakeRoot_fakeLeaf() throws {
		
		// This should succeed - as we are giving it the right cert.
		
		// Given
		let serverTrust = try XCTUnwrap(kitchenSinkServerTrust)
		
		// When
		let result = sut.check(
			serverTrust: serverTrust,
			policies: [policy],
			trustedCertificates: [fakeRoot])
		
		// Then
		expect(result) == true
	}
	
	func test_kitchenSinkServerTrust_realRoot_fakeLeaf() throws {
		
		// This should fail - as we are giving it the wrong cert.
		
		// Given
		let serverTrust = try XCTUnwrap(kitchenSinkServerTrust)
		
		// When
		let result = sut.check(
			serverTrust: serverTrust,
			policies: [policy],
			trustedCertificates: [realRoot])
		
		// Then
		expect(result) == false
	}
}
