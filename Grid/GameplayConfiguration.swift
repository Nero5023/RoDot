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
//    static let physizeBodySize: CGSize = CGSize(width: 22, height: <#T##CGFloat#>))
    static let physizeBodyWidth: CGFloat = 22
    
    static let collider: ColliderType = ColliderType(
      categoryBitMask: PhysicsCategory.Rod,
      collisionBitMask: PhysicsCategory.Ball,
      contactTestBitMask: PhysicsCategory.None)
    
    static let height: CGFloat = 210
  }
  
  struct RotationPoint {
    static let collider: ColliderType = ColliderType(
      categoryBitMask: PhysicsCategory.PointNode,
      collisionBitMask: PhysicsCategory.Ball,
      contactTestBitMask: PhysicsCategory.None)
    
    //Need to change
    static let radius: CGFloat = 11
  }
  
  struct PhysicsFactors {
    static let compoundangularVelocityFactor: CGFloat = 10
    static let pinJointFrictionTorque: CGFloat = 1
    static let pinJointRotationSpeed: CGFloat = 0.01
    static let restAngularVelocity: CGFloat = (π/4.0)/0.3
  }
}