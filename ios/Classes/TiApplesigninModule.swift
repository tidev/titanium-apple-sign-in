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

@objc(TiApplesigninModule)
class TiApplesigninModule: TiModule {
  
  func moduleGUID() -> String {
    return "cb40d586-ff2c-483e-8fac-69d1e82bd94c"
  }
  
  override func moduleId() -> String! {
    return "ti.applesignin"
  }

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

extension TiApplesigninModule: ASAuthorizationControllerDelegate {
  
  @available(iOS 13.0, *)
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    fireEvent("login", with: ["success": false, "error": error.localizedDescription])
  }
  
  @available(iOS 13.0, *)
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }

    guard let email = credential.email, let fullName = credential.fullName else {
      fireEvent("login", with: [["success": false, "error": NSLocalizedString("Cannot receive fields", comment: "")]])
      return;
    }

    var profile: [String: Any] = [
      "email": email,
      "name": [
        "firstName": fullName.givenName,
        "middleName": fullName.middleName,
        "nickname": fullName.nickname,
        "lastName": fullName.familyName,
        "namePrefix": fullName.namePrefix,
        "nameSuffix": fullName.nameSuffix
      ],
      "state": credential.state ?? "",
      "isRealUser": credential.realUserStatus == .likelyReal
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
