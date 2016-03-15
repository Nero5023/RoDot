//
//  RotateCountComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/14.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class RotateCountComponent: GKComponent {
  
  // MARK: Properties
  
  private var rotateCount: Int
  
  var intelligenceComponent: IntelligenceComponent {
    guard let intelligenceComponent = entity?.componentForClass(IntelligenceComponent.self) else {
      fatalError("The RotateCountComponent's entity must have a IntelligenceComponent")
    }
    return intelligenceComponent
  }
  
  // MARK: Initializers
  
  init(rotateCount: Int) {
    self.rotateCount = rotateCount
  }
  
  func endRotating() {
    rotateCount--
    if rotateCount == 0 {
      intelligenceComponent.stateMachine.enterState(PointLockedForeverState.self)
    }
  }
  
}
