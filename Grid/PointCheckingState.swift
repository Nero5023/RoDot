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
    guard let relateComponent = entity.component(ofType: RelateComponent.self) else {
      fatalError("The PointCheckingState's entity must have a RelateComponent")
    }
    return relateComponent
  }
  
  // Initializers
  
  required init(entity: BasePointEntity) {
    self.entity = entity
  }
  
  // MARK: GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    relateComponent.updateRelatedNodes()
        
    if let rotatableRodCount = entity.component(ofType: RotatableRodCountComponent.self)?.rotatableRodCount {
      if relateComponent.relateNodes.count == rotatableRodCount {
        stateMachine?.enter(PointUnlockedState)
      }else {
        stateMachine?.enter(PointLockedState)
      }
    }else {
      if relateComponent.relateNodes.count == 4 {
        stateMachine?.enter(PointLockedState)
      }else {
        stateMachine?.enter(PointUnlockedState)
      }
    }
  }
  
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    return stateClass is PointLockedState.Type || stateClass is PointUnlockedState.Type
  }
  
}
