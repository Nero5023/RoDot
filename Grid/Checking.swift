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
  
  override func didEnterWithPreviousState(previousState: GKState?) {
    node.userInteractionEnabled = false
    NSNotificationCenter.defaultCenter().postNotificationName(kPointNodeCheckNotification, object: self.node)
  }
  
  override func willExitWithNextState(nextState: GKState) {
    
  }
  
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass is Locked.Type || stateClass is Unlocked.Type
  }
  
  
}
