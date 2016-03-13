//
//  LevelSceneFailState.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/6.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class LevelSceneFailState: GKState {
  
  unowned let levelScene: LevelScene
  
  // MARK: Initializers
  
  init(levelScene: LevelScene) {
    self.levelScene = levelScene
  }
  
  // MARK: GKState Life Cycle
  
  override func didEnterWithPreviousState(previousState: GKState?) {
    super.didEnterWithPreviousState(previousState)
    
  }
  
  override func isValidNextState(stateClass: AnyClass) -> Bool {
    super.isValidNextState(stateClass)
    return stateClass is LevelSceneActiveState.Type
  }
}
