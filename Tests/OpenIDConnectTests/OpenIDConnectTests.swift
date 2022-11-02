/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import AppAuth
import OpenIDConnect
import OHHTTPStubs
import OHHTTPStubsSwift

final class OpenIDConnectTests: XCTestCase {

	private var sut: OpenIDConnectManager!
	private var openIDConnectStateSpy: OpenIDConnectStateSpy!
	
	override func setUp() {
		
		super.setUp()
	
		openIDConnectStateSpy = OpenIDConnectStateSpy()
		sut = OpenIDConnectManager()
	}
	
	override func tearDown() {
		
		super.tearDown()
		HTTPStubs.removeAllStubs()
	}
	
	func test_requestAccessToken_noInternet() {
		
		// Given
		let config = TestConfig()
		stub(condition: isPath("/.well-known/openid-configuration")) { _ in
			let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
			return HTTPStubsResponse(error: notConnectedError)
		}
		let exp = expectation(description: "test_discovery_noInternet")
		
		// When
		sut.requestAccessToken(issuerConfiguration: config, presentingViewController: nil, openIDConnectState: nil) { _ in
			
			// Then
			XCTFail("requestAccessToken should not return with success, there is a no internet error")
			exp.fulfill()
		} onError: { error in
			guard let error else {
				XCTFail("Could not unwrap error")
				exp.fulfill()
				return
			}
			let nsError = error as NSError
			XCTAssertEqual(nsError.code, OIDErrorCode.networkError.rawValue)
			exp.fulfill()
		}
		waitForExpectations(timeout: 3)
	}
	
	func test_requestAccessToken_cantOpenSafari() {
		
		// Given
		let config = TestConfig()
		stub(condition: isPath("/.well-known/openid-configuration")) { _ in
			
			return HTTPStubsResponse(
				jsonObject: self.valid_openid_configuration,
				statusCode: 200,
				headers: ["Content-Type":"application/json"]
			)
		}
		let exp = expectation(description: "test_requestAccessToken_cantOpenSafari")
		
		// When
		sut.requestAccessToken(
			issuerConfiguration: config,
			presentingViewController: nil,
			openIDConnectState: openIDConnectStateSpy) { _ in
			
			// Then
			XCTFail("OpenIDConnectStateSpy should not be able to open Safari")
			exp.fulfill()
		} onError: { error in
			guard let error else {
				XCTFail("Could not unwrap error")
				exp.fulfill()
				return
			}
			let nsError = error as NSError
			XCTAssertEqual(nsError.code, OIDErrorCode.safariOpenError.rawValue)
			XCTAssertTrue(self.openIDConnectStateSpy.invokedCurrentAuthorizationFlowSetter)
			exp.fulfill()
		}
		waitForExpectations(timeout: 3)
	}
	
	// MARK: - Helpers
	
	let valid_openid_configuration: [String : Any] = [
		"version": "3.0",
		"token_endpoint_auth_methods_supported": [
			"none"
		],
		"claims_parameter_supported": true,
		"request_parameter_supported": false,
		"request_uri_parameter_supported": true,
		"require_request_uri_registration": false,
		"grant_types_supported": [
			"authorization_code"
		],
		"frontchannel_logout_supported": false,
		"frontchannel_logout_session_supported": false,
		"backchannel_logout_supported": false,
		"backchannel_logout_session_supported": false,
		"issuer": "https://example.com",
		"authorization_endpoint": "https://example.com/authorize",
		"jwks_uri": "https://example.com/jwks",
		"token_endpoint": "https://example.com/accesstoken",
		"scopes_supported": [
			"openid"
		],
		"response_types_supported": [
			"code"
		],
		"response_modes_supported": [
			"query"
		],
		"subject_types_supported": [
			"pairwise"
		],
		"id_token_signing_alg_values_supported": [
			"RS256"
		]
	]
}

final class TestConfig: OpenIDConnectConfiguration {
	
	var issuerUrl: URL { return URL(string: "https://example.com")!}
	var clientId: String { return "test" }
	var redirectUri: URL { return URL(string: "https://app.com/app/auth")!}
}
