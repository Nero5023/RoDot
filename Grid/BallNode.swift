//
//  BallNode.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/19.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit

class BallNode: SKSpriteNode, CustomNodeEvents {
  
  func didMoveToScene() {
    physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
    
    physicsBody!.categoryBitMask = PhysicsCategory.Ball
    physicsBody!.collisionBitMask = PhysicsCategory.Rod | PhysicsCategory.PointNode | PhysicsCategory.Edge
    physicsBody!.mass = 0.15
  }
}
