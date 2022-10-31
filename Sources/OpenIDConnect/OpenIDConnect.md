# OpenIDConnect

This package contains helper to simplify the implementation of [OpenID](https://github.com/openid/AppAuth-iOS). 

## Usage

For each openID server you want to connect with, you'll need to create an `OpenIDConnectConfiguration`

```swift
import OpenIDConnect

class MyOpenIDConnectConfiguration: OpenIDConnectConfiguration {
	
	var issuerUrl: URL {return URL(string: "url of the openID server")}
	
	var clientId: String {return "the Id for the client (this app)"}
	
	var redirectUri: URL {return URL(string: "url to call when the call is completed which redirect to the app")}
}

```

An example of a ViewModel presenting a browser for the user to connect to the openID server:

```swift
class AuthenticationViewModel {
	private weak var openIDConnectManager: OpenIDConnectManaging?
	private var openIDConnectState: OpenIDConnectState?
	private var openIDConnectConfiguration: OpenIDConnectConfiguration
	
	init(
		openIDConnectManager: OpenIDConnectManaging?,
		openIDConnectConfiguration: OpenIDConnectConfiguration = MyOpenIDConnectConfiguration()) {
			self.openIDConnectManager = openIDConnectManager
			self.openIDConnectConfiguration = openIDConnectConfiguration
		}
	
	// use the internal browser for web based openID,
	// use the external browser for app based openID, then set presentingViewController to nil
	func login(presentingViewController: UIViewController?) {
		
		openIDConnectManager?.requestAccessToken(
			issuerConfiguration: openIDConnectConfiguration,
			presentingViewController: presentingViewController,
			onCompletion: { (token: OpenIDConnectToken) in
        // Success! We now have the token from the openID server.
				// It is an openIDConnectToken, with the fields: idToken and accessToken.
			},
			onError: { error in
				if let error {
					if error.localizedDescription.contains("saml_authn_failed") ||
						error.localizedDescription.contains("cancelled:") ||
						error.code == OIDErrorCode.userCanceledAuthorizationFlow.rawValue {
						print("User cancelled")
						// handle the case the user cancelled the flow
						return
					} else {
             print(error)    
          }
				}
			}
		)
	}
}
```



We need to handle the return redirect (Deep Link or Universal Link):

```swift
import OpenIDConnect

@main
class AppDelegate: UIResponder, UIApplicationDelegate, OpenIDConnectState {

	// login flow
	var currentAuthorizationFlow: OIDExternalUserAgentSession?
	
  ...
  
	/// For handling __Deep Links__ only, - not relevant for Universal Links.
	func application(
		_ app: UIApplication,
		open url: URL,
		options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
			
			// Sends the URL to the current authorization flow (if any) which will
			// process it if it relates to an authorization response.
			if let authorizationFlow = self.currentAuthorizationFlow,
			   authorizationFlow.resumeExternalUserAgentFlow(with: url) {
				self.currentAuthorizationFlow = nil
				return true
			}
			
			// Your additional URL handling (if any)
			
			return false
		}
  
	/// Entry point for Universal links in iOS 11/12 only (see SceneDelegate for iOS 13+)
	/// Used for both running and cold-booted apps
	func application(_: UIApplication, continue userActivity: NSUserActivity, restorationHandler _: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
		
		// Apple's docs specify to only handle universal links "with the activityType set to NSUserActivityTypeBrowsingWeb"
		guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
			  let url = userActivity.webpageURL
		else { return false }
		
		if url.path.hasPrefix("path from MyOpenIDConnectConfiguration redirect uri"),
        let authorizationFlow = self.currentAuthorizationFlow,
			  authorizationFlow.resumeExternalUserAgentFlow(with: url) {
				self.currentAuthorizationFlow = nil
				return true
		}
		return false
	}
  
}
```

If you are using a SceneDelegate:

```swift
import OpenIDConnect

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
...
  	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {

		if let url = URLContexts.first?.url,
		   let openIDConnectState = UIApplication.shared.delegate as? OpenIDConnectState,
		   let authorizationFlow = appAuthState.currentAuthorizationFlow,
		   authorizationFlow.resumeExternalUserAgentFlow(with: url) {
			openIDConnectState.currentAuthorizationFlow = nil
		}
	}
}
  
```



## License

License is released under the EUPL 1.2 license. [See LICENSE](https://github.com/minvws/nl-rdo-app-ios-modules/blob/master/LICENSE.txt) for details.
