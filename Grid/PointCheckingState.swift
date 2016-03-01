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
    if relateComponent.relateNodes.count == 4 {
      stateMachine?.enterState(PointLockedState)
    }else {
      stateMachine?.enterState(PointUnlockedState)
    }
  }
  
  
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass is PointLockedState.Type || stateClass is PointUnlockedState.Type
  }
  
}
