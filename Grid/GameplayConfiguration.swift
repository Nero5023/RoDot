//
//  GameplayConfiguration.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/24.
//  Copyright © 2016年 Nero. All rights reserved.
//

import Foundation
import CoreGraphics

struct GameplayConfiguration {
  struct Rod {
    static let physizeBodyWidth: CGFloat = 22
    
    static let collider: ColliderType = ColliderType(
      categoryBitMask: PhysicsCategory.Rod,
      collisionBitMask: PhysicsCategory.Ball ,
      contactTestBitMask: PhysicsCategory.None)
    
    static let height: CGFloat = 204
    
    static let zPosition: CGFloat = 60
  }
  
  struct RotationPoint {
    static let collider: ColliderType = ColliderType(
      categoryBitMask: PhysicsCategory.PointNode,
      collisionBitMask: PhysicsCategory.Ball,
      contactTestBitMask: PhysicsCategory.None)
    
    static let radius: CGFloat = 25
    
    static let zPositon: CGFloat = 70
  }
  
  // The physics factors in the game
  struct PhysicsFactors {
    static let compoundangularVelocityFactor: CGFloat = 10
    static let pinJointFrictionTorque: CGFloat = 1
    static let pinJointRotationSpeed: CGFloat = 0.01
    static let restAngularVelocity: CGFloat = (π/4.0)/0.3
    static let restLinerVelocity: CGFloat = 105 / 0.3
  }
  
  struct Transfer {
    static let collider: ColliderType = ColliderType(
      categoryBitMask: PhysicsCategory.Transfer,
      collisionBitMask: PhysicsCategory.None,
      contactTestBitMask: PhysicsCategory.Ball | PhysicsCategory.IceBall)
    
    static let phybodyRadius: CGFloat = 50
    
     static let zPosition: CGFloat = 50
  }
  
  static let transferTargetNames: [String: String] = ["transfer0": "transfer1", "transfer1": "transfer0"]
}