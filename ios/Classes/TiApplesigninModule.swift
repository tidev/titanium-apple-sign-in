/**
* Axway Titanium
* Copyright (c) 2018-present by Axway Appcelerator. All Rights Reserved.
* Licensed under the terms of the Apache Public License
* Please see the LICENSE included with this distribution for details.
*/

import AuthenticationServices
import UIKit
import TitaniumKit

@available(iOS 15.0, *)
@objc(TiApplesigninModule)
class TiApplesigninModule: TiModule {
  
  // MARK: Public constants
  
  @objc let BUTTON_TYPE_DEFAULT = ASAuthorizationAppleIDButton.ButtonType.default.rawValue

  @objc let BUTTON_TYPE_CONTINUE = ASAuthorizationAppleIDButton.ButtonType.continue.rawValue

  @objc let BUTTON_TYPE_SIGN_IN = ASAuthorizationAppleIDButton.ButtonType.signIn.rawValue
  
  @objc let BUTTON_STYLE_WHITE = ASAuthorizationAppleIDButton.Style.white.rawValue

  @objc let BUTTON_STYLE_WHITE_OUTLINE = ASAuthorizationAppleIDButton.Style.whiteOutline.rawValue

  @objc let BUTTON_STYLE_BLACK = ASAuthorizationAppleIDButton.Style.black.rawValue
  
  @objc let CREDENTIAL_STATE_AUTHORIZED = ASAuthorizationAppleIDProvider.CredentialState.authorized

  @objc let CREDENTIAL_STATE_NOT_FOUND = ASAuthorizationAppleIDProvider.CredentialState.notFound

  @objc let CREDENTIAL_STATE_REVOKED = ASAuthorizationAppleIDProvider.CredentialState.revoked

  @objc let CREDENTIAL_STATE_TRANSFERRED = ASAuthorizationAppleIDProvider.CredentialState.transferred
    
  @objc let AUTHORIZATION_SCOPE_FULLNAME = ASAuthorization.Scope.fullName

  @objc let AUTHORIZATION_SCOPE_EMAIL = ASAuthorization.Scope.email

  @objc let USER_DETECTION_STATUS_REAL = ASUserDetectionStatus.likelyReal
    
  @objc let USER_DETECTION_STATUS_UNSUPPORTED = ASUserDetectionStatus.unsupported
    
  @objc let USER_DETECTION_STATUS_UNKNOWN = ASUserDetectionStatus.unknown

  // MARK: Private state

  private var isDeletingAccount = false
  private var deleteAccountCallback: KrollCallback?
  private var deleteAccountBackendURL: String?

  // MARK: Lifecycle

  override func startup() {
    super.startup()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleCredentialRevoked),
      name: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @objc private func handleCredentialRevoked() {
    fireEvent("credentialRevoked", with: [:])
  }

    
  // MARK: Proxy configuration

  func moduleGUID() -> String {
    return "cb40d586-ff2c-483e-8fac-69d1e82bd94c"
  }
  
  override func moduleId() -> String! {
    return "ti.applesignin"
  }
  
  // MARK: Public API's
  @objc(authorize:)
  func authorize(arguments: Array<Any>?) {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    
    if let params = arguments?.first as? [String: Any] {
      // Nonce support for backend safety (ex: Firebase)
      if let nonce = params["nonce"] as? String {
        request.nonce = nonce
      }
      if let scopes = params["scopes"] as? [String] {
        request.requestedScopes = scopes.map { ASAuthorization.Scope($0) }
      } else {
        request.requestedScopes = [.fullName, .email]
      }
    } else {
      request.requestedScopes = [.fullName, .email]
    }
    
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.performRequests()
  }

  @objc(checkExistingAccounts:)
  func checkExistingAccounts(arguments: Any?) {
    // Prepare requests for both Apple ID and password providers.
    let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                    ASAuthorizationPasswordProvider().createRequest()]
    
    // Create an authorization controller with the given requests.
    let authorizationController = ASAuthorizationController(authorizationRequests: requests)
    authorizationController.delegate = self
    authorizationController.performRequests()
  }
  
  @objc(getCredentialState:)
  func getCredentialState(arguments: Array<Any>?) {
    guard let arguments = arguments,
      arguments.count == 2,
      let userId = arguments.first as? String,
      let callback = arguments[1] as? KrollCallback else { return }

    ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userId) { (credentialState, error) in
      callback.call([["state": credentialState.rawValue]], thisObject: self)
    }
  }

  // MARK: Delete Account

  /**
   * Deletes the user account by:
   * 1. Re-authenticating with Apple to get a fresh authorizationCode
   * 2. Sending the code to your backend which calls Apple's revoke endpoint
   * 3. Returning success/failure via callback
   *
   * JS usage:
   *   appleSignIn.deleteAccount({
   *     backendURL: 'https://yourbackend.com/apple/revoke'
   *   }, function(result) {
   *     if (result.success) { ... }
   *   });
   */
  @objc(deleteAccount:)
  func deleteAccount(arguments: Array<Any>?) {
    guard let arguments = arguments,
          arguments.count == 2,
          let params = arguments[0] as? [String: Any],
          let backendURL = params["backendURL"] as? String,
          let callback = arguments[1] as? KrollCallback else {
      return
    }

    self.deleteAccountCallback = callback
    self.deleteAccountBackendURL = backendURL
    self.isDeletingAccount = true

    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = []

    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
  }

  private func revokeAndFinish(authorizationCode: String) {
    guard let backendURL = deleteAccountBackendURL,
          let url = URL(string: backendURL) else {
      fireDeleteCallback(success: false, error: "Invalid backend URL")
      return
    }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
      urlRequest.httpBody = try JSONSerialization.data(withJSONObject: [
        "authorization_code": authorizationCode
      ])
    } catch {
      fireDeleteCallback(success: false, error: "Failed to serialize request body")
      return
    }

    URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
      guard let self = self else { return }

      if let error = error {
        self.fireDeleteCallback(success: false, error: error.localizedDescription)
        return
      }

      guard let data = data,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let success = json["success"] as? Bool else {
        self.fireDeleteCallback(success: false, error: "Invalid response from backend")
        return
      }

      if success {
        self.fireDeleteCallback(success: true, error: nil)
      } else {
        let errorMsg = json["error"] as? String ?? "Unknown error from backend"
        self.fireDeleteCallback(success: false, error: errorMsg)
      }
    }.resume()
  }

  private func fireDeleteCallback(success: Bool, error: String?) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      var result: [String: Any] = ["success": success]
      if let error = error { result["error"] = error }
      self.deleteAccountCallback?.call([result], thisObject: self)
      self.deleteAccountCallback = nil
      self.deleteAccountBackendURL = nil
      self.isDeletingAccount = false
    }
  }
}

// MARK: ASAuthorizationControllerDelegate
extension TiApplesigninModule: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    if isDeletingAccount {
      let nsError = error as NSError
      let cancelled = [1_000, 1_001].contains(nsError.code)
      fireDeleteCallback(
        success: false,
        error: cancelled ? "User cancelled" : error.localizedDescription
      )
      return
    }

    let error = error as NSError
    let cancelErrorCodes = [1_000, 1_001]

    if cancelErrorCodes.contains(error.code) {
      fireEvent("login", with: ["success": false, "cancelled": true])
      return
    }
    fireEvent("login", with: ["success": false, "cancelled": false, "error": error.localizedDescription])
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let passwordCredential = authorization.credential as? ASPasswordCredential {
      fireEvent("login", with: ["credentialType": "password", "success": true, "user": passwordCredential.user, "password": passwordCredential.password])
      return
    }
  
    guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }

    if isDeletingAccount {
      guard let authorizationCode = credential.authorizationCode,
            let codeString = String(data: authorizationCode, encoding: .utf8) else {
        fireDeleteCallback(success: false, error: "Failed to obtain authorization code from Apple")
        return
      }
      revokeAndFinish(authorizationCode: codeString)
      return
    }

    var profile: [String: Any] = [
      "userId": credential.user,
      "state": credential.state ?? "",
      "realUserStatus": credential.realUserStatus.rawValue,
      "authorizedScopes": credential.authorizedScopes.map({ $0.rawValue })
    ]
    
    if let email = credential.email {
      profile["email"] = email
    }
    
    if let fullName = credential.fullName {
      profile["name"] = [
        "firstName": fullName.givenName,
        "middleName": fullName.middleName,
        "nickname": fullName.nickname,
        "lastName": fullName.familyName,
        "namePrefix": fullName.namePrefix,
        "nameSuffix": fullName.nameSuffix
      ]
    }

    if let identityToken = credential.identityToken {
      profile["identityToken"] = String(data: identityToken, encoding: .utf8)
    }

    if let authorizationCode = credential.authorizationCode {
      profile["authorizationCode"] = String(data: authorizationCode, encoding: .utf8)
    }
    
    fireEvent("login", with: ["credentialType": "apple", "success": true, "profile": profile])
  }
}

// MARK: ASAuthorizationControllerPresentationContextProviding

extension TiApplesigninModule: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    if #available(iOS 15.0, *) {
      guard let scene = UIApplication.shared.connectedScenes
              .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let window = scene.windows.first(where: { $0.isKeyWindow }) else {
        return UIWindow()
      }
        return window
    } else {
      return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
  }
}
