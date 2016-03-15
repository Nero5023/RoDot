//
//  PointCheckingState.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/27.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class PointCheckingState: GKState {
  
  // MARK: Properties
  
  unowned var entity: BasePointEntity
  
  private var isFirstTime: Bool = true
  
  var relateComponent: RelateComponent {
    guard let relateComponent = entity.componentForClass(RelateComponent.self) else {
      fatalError("The PointCheckingState's entity must have a RelateComponent")
    }
    return relateComponent
  }
  
  // Initializers
  
  required init(entity: BasePointEntity) {
    self.entity = entity
  }
  
  // MARK: GKState Life Cycle
  
  override func didEnterWithPreviousState(previousState: GKState?) {
    super.didEnterWithPreviousState(previousState)
    relateComponent.updateRelatedNodes()
    
    if isFirstTime {
      isFirstTime = false
    }else if let rotateCountComponent = entity.componentForClass(RotateCountComponent.self) {
      rotateCountComponent.endRotating()
    }
    
    if let rotatableRodCount = entity.componentForClass(RotatableRodCountComponent.self)?.rotatableRodCount {
      if relateComponent.relateNodes.count == rotatableRodCount {
        stateMachine?.enterState(PointUnlockedState)
      }else {
        stateMachine?.enterState(PointLockedState)
      }
    }else {
      if relateComponent.relateNodes.count == 4 {
        stateMachine?.enterState(PointLockedState)
      }else {
        stateMachine?.enterState(PointUnlockedState)
      }
    }
  }
  
  
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass is PointLockedState.Type || stateClass is PointUnlockedState.Type || stateClass is PointLockedForeverState.Type
  }
  
}
