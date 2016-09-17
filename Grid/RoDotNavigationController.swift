//
//  RoDotNavigationController.swift
//  Grid
//
//  Created by Nero Zuo on 16/4/10.
//  Copyright © 2016年 Nero. All rights reserved.
//

import UIKit

class RoDotNavigationController: UINavigationController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(RoDotNavigationController.showAuthenticationViewController), name: NSNotification.Name(rawValue: PresentAuthenticationViewController), object: nil)
    
    GameKitHelper.shareInstance.authenticateLocalPlayer()
  }
  
  func showAuthenticationViewController() {
    let gameKitHelper = GameKitHelper.shareInstance
    
    if let authenticationViewController = gameKitHelper.authenticationViewController {
      topViewController?.present(authenticationViewController, animated: true, completion: nil)
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
