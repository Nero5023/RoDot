//
//  Rotating.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/11.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class Rotating: GKState {
  unowned let node: RotationPointNode
  
  init(node: SKSpriteNode) {
    self.node = node as! RotationPointNode
    super.init()
  }
  
  override func didEnterWithPreviousState(previousState: GKState?) {
    if let scene = node.scene as? GameScene {
//      scene.gridGraph.attachJointFixToPointNode(node, )
      scene.gridGraph.attachJointFixToPointNode(node, atScene: scene)
    }
  }
  
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass is Checking.Type
  }
  
  
}