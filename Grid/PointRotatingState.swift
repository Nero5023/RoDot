//
//  PointRotatingState.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/27.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class PointRotatingState: GKState {
  
  // MARK: Properties
  
  unowned var entity: BasePointEntity
  
  // Initializers
  
  required init(entity: BasePointEntity) {
    self.entity = entity
  }
  
  // MARK: GKState Life Cycle
  
  override func didEnterWithPreviousState(previousState: GKState?) {
    let soundOpenLock = SKAction.playSoundFileNamed("open_lock.wav", waitForCompletion: false)
    self.entity.componentForClass(RenderComponent.self)?.node.runAction(soundOpenLock)
  }
  
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass is PointCheckingState.Type || stateClass is PointUnlockedState.Type
  }

}
