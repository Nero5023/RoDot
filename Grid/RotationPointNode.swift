//
//  RotationPointNode.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/10.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class RotationPointNode: SKSpriteNode, CustomNodeEvents {
  lazy var state: GKStateMachine = GKStateMachine(states: [
    Checking(node: self),
    Locked(node: self),
    Unlocked(node: self),
    Rotating(node: self)
    ])
  
  func didMoveToScene() {
    state.enterState(Checking)
//    physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
    physicsBody = SKPhysicsBody(circleOfRadius: size.width/4)
    physicsBody?.affectedByGravity = false
    physicsBody?.dynamic = false
    
    
  }
  
  
}
