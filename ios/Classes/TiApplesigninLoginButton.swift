/**
 * Axway Titanium
 * Copyright (c) 2018-present by Axway Appcelerator. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

import AuthenticationServices
import TitaniumKit

@available(iOS 13.0, *)
@objc(TiApplesigninLoginButton)
public class TiApplesigninLoginButton : TiUIView {
  
  var loginButton: ASAuthorizationAppleIDButton?

  public override func initializeState() {
    super.initializeState()
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.loginButtonTapped))
    
    var type: ButtonType = .default
    var style: ButtonStyle = .black

    if let proxyType = proxy.value(forKey: "type") as? Int, let authorizationButtonType = ButtonType(rawValue: proxyType) {
      type = authorizationButtonType
    }

    if let proxyStyle = proxy.value(forKey: "style") as? Int, let authorizationButtonStyle = ButtonStyle(rawValue: proxyStyle) {
      style = authorizationButtonStyle
    }

    loginButton = ASAuthorizationAppleIDButton(authorizationButtonType:  type, authorizationButtonStyle: style)
    loginButton?.addGestureRecognizer(tapRecognizer)

    if let cornerRadius = proxy.value(forKey: "borderRadius") as? Float {
      loginButton?.cornerRadius = CGFloat(cornerRadius)
    }

    self.addSubview(loginButton!)
  }
  
  @objc func loginButtonTapped() {
    proxy.fireEvent("click")
  }
}
