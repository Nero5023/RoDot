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
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RoDotNavigationController.showAuthenticationViewController), name: PresentAuthenticationViewController, object: nil)
    
    GameKitHelper.shareInstance.authenticateLocalPlayer()
  }
  
  func showAuthenticationViewController() {
    let gameKitHelper = GameKitHelper.shareInstance
    
    if let authenticationViewController = gameKitHelper.authenticationViewController {
      topViewController?.presentViewController(authenticationViewController, animated: true, completion: nil)
    }
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}
