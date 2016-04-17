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
//    size = CGSize(width: 150, height: 150)
    physicsBody!.categoryBitMask = PhysicsCategory.Ball
    physicsBody!.collisionBitMask = PhysicsCategory.Rod | PhysicsCategory.PointNode | PhysicsCategory.Ball | PhysicsCategory.IceBall
    physicsBody!.contactTestBitMask = PhysicsCategory.Transfer | PhysicsCategory.Distance | PhysicsCategory.Edge 
    physicsBody!.mass = 0.015
//    physicsBody!.mass = 0.197511121630669
//    physicsBody!.allowsRotation = false
//    physicsBody!.usesPreciseCollisionDetection = true
    zPosition = 1000
  }
}
