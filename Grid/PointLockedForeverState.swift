//
//  PointLockedForeverState.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/1.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class PointLockedForeverState: GKState {
  
  // MARK: Properties
  
  unowned var entity: BasePointEntity
  
  // Initializers
  
  required init(entity: BasePointEntity) {
    self.entity = entity
  }

  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return false
  }
}
