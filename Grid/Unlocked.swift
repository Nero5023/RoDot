//
//  Unlocked.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/11.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class Unlocked: GKState {
  unowned let node: RotationPointNode
  
  init(node: SKSpriteNode) {
    self.node = node as! RotationPointNode
    super.init()
  }
  
  override func didEnterWithPreviousState(previousState: GKState?) {
    node.userInteractionEnabled = true
  }
  
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass is Checking.Type || stateClass is Rotating.Type
  }
  
}
