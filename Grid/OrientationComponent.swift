//
//  OrientationComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/25.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

// According to the render zRoation to decide vertical or horizontal for node
enum HVDirection: Int {
  case horizontal = 0, vertical, otherDirection
  
  init(zRotation: CGFloat) {
    if zRotation < 0.1 || abs(zRotation - π) < 0.1 || abs(zRotation - 2*π) < 0.1{
      self = .vertical
      return
    }
    
    if abs(zRotation - π/2.0) < 0.1 || abs(zRotation - 1.5*π) < 0.1 {
      self = .horizontal
      return
    }
    
    self = .otherDirection
  }
}

class OrientationComponent: GKComponent {
  
  // MARK: Properties
  
  var zRotation: CGFloat = 0 {
    didSet {
      zRotation = (zRotation + 2*π) % (2*π)
    }
  }
  
  var direction: HVDirection {
    get {
      return HVDirection(zRotation: zRotation)
    }
  }
  
}
