//
//  PhysicsComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/24.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class PhysicsComponent: GKComponent {
  
  // MARK: Properties
  
  var physicsBody: SKPhysicsBody
  
  // MARK: Initializers
  
  init(physicsBody: SKPhysicsBody, colliderType: ColliderType) {
    self.physicsBody = physicsBody
    physicsBody.categoryBitMask = colliderType.categoryBitMask
    physicsBody.collisionBitMask = colliderType.collisionBitMask
    physicsBody.contactTestBitMask = colliderType.contactTestBitMask
  }
  
}

