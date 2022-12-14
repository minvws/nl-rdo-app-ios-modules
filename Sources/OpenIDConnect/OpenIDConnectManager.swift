/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import AppAuth

public class OpenIDConnectManager: OpenIDConnectManaging {
	
	public init() {}
	
	/// Request an access token
	/// - Parameters:
	///   - issuerConfiguration: openID configuration
	///   - presentingViewController: an optional view controller that presents the authentication view
	///   - openIDConnectState: the state of the current connection
	///   - onCompletion: completion handler with the access token
	///   - onError: the error handler
	public func requestAccessToken(
		issuerConfiguration: OpenIDConnectConfiguration,
		presentingViewController: UIViewController?,
		openIDConnectState: OpenIDConnectState? = UIApplication.shared.delegate as? OpenIDConnectState,
		onCompletion: @escaping (OpenIDConnectToken) -> Void,
		onError: @escaping (Error?) -> Void) {
			
			discoverServiceConfiguration(issuerConfiguration: issuerConfiguration) { [weak self] result in
				switch result {
					case let .success(serviceConfiguration):
						self?.requestAuthorization(
							issuerConfiguration: issuerConfiguration,
							serviceConfiguration: serviceConfiguration,
							presentingViewController: presentingViewController,
							openIDConnectState: openIDConnectState,
							onCompletion: onCompletion,
							onError: onError
						)
						
					case let .failure(error):
						onError(error)
				}
			}
		}
	
	private func requestAuthorization(
		issuerConfiguration: OpenIDConnectConfiguration,
		serviceConfiguration: OIDServiceConfiguration,
		presentingViewController: UIViewController?,
		openIDConnectState: OpenIDConnectState?,
		onCompletion: @escaping (OpenIDConnectToken) -> Void,
		onError: @escaping (Error?) -> Void) {
			
			let request = generateRequest(
				issuerConfiguration: issuerConfiguration,
				serviceConfiguration: serviceConfiguration
			)
			
			if let openIDConnectState {
				
				if #unavailable(iOS 13) {
					NotificationCenter.default.post(name: .launchingOpenIDConnectBrowser, object: nil)
				}
				
				let callBack: OIDAuthStateAuthorizationCallback = { authState, error in
					
					NotificationCenter.default.post(name: .closingOpenIDConnectBrowser, object: nil)
					DispatchQueue.main.async {
						
						if let lastTokenResponse = authState?.lastTokenResponse {
							onCompletion(lastTokenResponse)
						} else {
							onError(error)
						}
					}
				}
				
				if let presentingViewController {
					openIDConnectState.currentAuthorizationFlow = OIDAuthState.authState(
						byPresenting: request,
						presenting: presentingViewController,
						callback: callBack
					)
				} else {
					openIDConnectState.currentAuthorizationFlow = OIDAuthState.authState(
						byPresenting: request,
						externalUserAgent: OIDExternalUserAgentIOSCustomBrowser.defaultBrowser() ?? OIDExternalUserAgentIOSCustomBrowser.customBrowserSafari(),
						callback: callBack
					)
				}
			}
		}
	
	/// Discover the configuration file for the open ID connection
	/// - Parameters:
	///   - issuerConfiguration: The openID configuration
	///   - onCompletion: Service Configuration or error
	private func discoverServiceConfiguration(issuerConfiguration: OpenIDConnectConfiguration, onCompletion: @escaping (Result<OIDServiceConfiguration, Error>) -> Void) {
		
		OIDAuthorizationService.discoverConfiguration(forIssuer: issuerConfiguration.issuerUrl) { serviceConfiguration, error in
			DispatchQueue.main.async {
				if let serviceConfiguration {
					onCompletion(.success(serviceConfiguration))
				} else if let error {
					onCompletion(.failure(error))
				}
			}
		}
	}
	
	/// Generate an Authorization Request
	/// - Parameter
	///   - issuerConfiguration: The openID configuration
	///   - serviceConfiguration: Service Configuration
	/// - Returns: Open Id Authorization Request
	private func generateRequest(issuerConfiguration: OpenIDConnectConfiguration, serviceConfiguration: OIDServiceConfiguration) -> OIDAuthorizationRequest {
		
		// builds authentication request
		let request = OIDAuthorizationRequest(
			configuration: serviceConfiguration,
			clientId: issuerConfiguration.clientId,
			scopes: [OIDScopeOpenID],
			redirectURL: issuerConfiguration.redirectUri,
			responseType: OIDResponseTypeCode,
			additionalParameters: nil
		)
		return request
	}
}
