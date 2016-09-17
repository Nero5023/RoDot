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
  
  override func didEnter(from previousState: GKState?) {
    if let previousState = previousState {
      if previousState is PointRotatingState {
        if let rotateCountComponent = entity.component(ofType: RotateCountComponent.self) {
          rotateCountComponent.endRotating()
        }
      }
    }
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is PointCheckingState.Type || stateClass is PointRotatingState.Type || stateClass is PointLockedForeverState.Type || stateClass is PointTranslatingState.Type
  }
}
