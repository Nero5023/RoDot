//
//  Locked.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/11.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class Locked: GKState {
  unowned let node: RotationPointNode
  
  init(node: SKSpriteNode) {
    self.node = node as! RotationPointNode
    super.init()
  }
  
  override func didEnter(from previousState: GKState?) {
    
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is Checking.Type
  }
  
}
