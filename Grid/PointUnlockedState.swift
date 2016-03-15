//
//  PointUnlockedState.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/27.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class PointUnlockedState: GKState {
  
  // MARK: Properties
  
  unowned var entity: BasePointEntity
  
  // Initializers
  
  required init(entity: BasePointEntity) {
    self.entity = entity
  }
  
  // MARK: GKState Life Cycle
  
  override func didEnterWithPreviousState(previousState: GKState?) {
    if let previousState = previousState {
      if previousState is PointRotatingState {
        if let rotateCountComponent = entity.componentForClass(RotateCountComponent.self) {
          rotateCountComponent.endRotating()
        }
      }
    }
  }
  
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass is PointCheckingState.Type || stateClass is PointRotatingState.Type || stateClass is PointLockedForeverState.Type
  }
}
