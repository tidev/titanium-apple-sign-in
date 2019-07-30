//
//  TiApplesigninModule.swift
//  titanium-apple-sign-in
//
//  Created by Your Name
//  Copyright (c) 2019 Your Company. All rights reserved.
//

import AuthenticationServices
import UIKit
import TitaniumKit

@available(iOS 13.0, *)
@objc(TiApplesigninModule)
class TiApplesigninModule: TiModule {
  
  // MARK: Public constants
  
  @objc let BUTTON_TYPE_DEFAULT = ButtonType.default.rawValue

  @objc let BUTTON_TYPE_CONTINUE = ButtonType.continue.rawValue

  @objc let BUTTON_TYPE_SIGN_IN = ButtonType.signIn.rawValue
  
  @objc let BUTTON_STYLE_WHITE = ButtonStyle.white.rawValue

  @objc let BUTTON_STYLE_WHITE_OUTLINE = ButtonStyle.whiteOutline.rawValue

  @objc let BUTTON_STYLE_BLACK = ButtonStyle.black
  
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

    guard let email = credential.email, let fullName = credential.fullName else {
      fireEvent("login", with: [["success": false, "cancelled": false, "error": NSLocalizedString("Cannot receive fields", comment: "")]])
      return;
    }

    var profile: [String: Any] = [
      "email": email,
      "state": credential.state ?? "",
      "isRealUser": credential.realUserStatus == .likelyReal,
      "name": [
        "firstName": fullName.givenName,
        "middleName": fullName.middleName,
        "nickname": fullName.nickname,
        "lastName": fullName.familyName,
        "namePrefix": fullName.namePrefix,
        "nameSuffix": fullName.nameSuffix
      ],
    ]

    if let identityToken = credential.identityToken {
      profile["identityToken"] = String(data: identityToken, encoding: .utf8)
    }

    if let authorizationCode = credential.authorizationCode {
      profile["authorizationCode"] = String(data: authorizationCode, encoding: .utf8)
    }
    
    fireEvent("login", with: ["success": true, "profile": profile])
  }
}
