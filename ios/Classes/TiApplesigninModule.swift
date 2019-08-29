/**
* Axway Titanium
* Copyright (c) 2018-present by Axway Appcelerator. All Rights Reserved.
* Licensed under the terms of the Apache Public License
* Please see the LICENSE included with this distribution for details.
*/

import AuthenticationServices
import UIKit
import TitaniumKit

@available(iOS 13.0, *)
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

    
  // MARK: Proxy configuration

  func moduleGUID() -> String {
    return "cb40d586-ff2c-483e-8fac-69d1e82bd94c"
  }
  
  override func moduleId() -> String! {
    return "ti.applesignin"
  }
  
  // MARK: Public API's

  @available(iOS 13.0, *)
  @objc(authorize:)
  func authorize(arguments: Array<Any>?) {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    
    if let params = arguments?.first as? [String: Any], let scopes = params["scopes"] as? [String] {
      scopes.forEach { scope in
        request.requestedScopes?.append(ASAuthorization.Scope(scope))
      }
    } else {
      request.requestedScopes = [.fullName, .email]
    }
    
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.performRequests()
  }

  @available(iOS 13.0, *)
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
}

// MARK: ASAuthorizationControllerDelegate

@available(iOS 13.0, *)
extension TiApplesigninModule: ASAuthorizationControllerDelegate {
  
  @available(iOS 13.0, *)
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    let error = error as NSError
    
    if error.code == 1_001 {
      fireEvent("login", with: ["success": false, "cancelled": true])
      return
    }
    fireEvent("login", with: ["success": false, "cancelled": false, "error": error.localizedDescription])
  }
  
  @available(iOS 13.0, *)
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }

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
    
    fireEvent("login", with: ["success": true, "profile": profile])
  }
}
