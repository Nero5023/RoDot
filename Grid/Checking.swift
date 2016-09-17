//
//  Checking.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/11.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation

let kPointNodeCheckNotification = "kPointNodeCheckNotification"

class Checking: GKState {
  unowned let node: RotationPointNode
  
  init(node: SKSpriteNode) {
    self.node = node as! RotationPointNode
    super.init()
  }
  
  override func didEnter(from previousState: GKState?) {
    node.isUserInteractionEnabled = false
    NotificationCenter.default.post(name: Notification.Name(rawValue: kPointNodeCheckNotification), object: self.node)
  }
  
  override func willExit(to nextState: GKState) {
    
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is Locked.Type || stateClass is Unlocked.Type
  }
  
  
}
