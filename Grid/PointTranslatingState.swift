//
//  PointTranslatingState.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/6.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit


class PointTranslatingState: GKState {
  
  // MARK: Properties
  
  unowned var entity: BasePointEntity
  
  // Initializers
  
  required init(entity: BasePointEntity) {
    self.entity = entity
  }
  
  // MARK: GKState Life Cycle
  
  override func didEnterWithPreviousState(previousState: GKState?) {
    SKTAudio.sharedInstance().playSoundEffect("open_lock_2.wav", withVolume: 0.33)
  }
  
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    return stateClass is PointCheckingState.Type || stateClass is PointTranslatingState.Type || stateClass is PointUnlockedState.Type
  }
  
}
