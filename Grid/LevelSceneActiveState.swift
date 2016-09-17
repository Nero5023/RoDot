//
//  LevelSceneActiveState.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/6.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class LevelSceneActiveState: GKState {
  
  // MARK: Properties
  
  unowned let levelScene: LevelScene
  
  // MARK: Initializers
  
  init(levelScene: LevelScene) {
    self.levelScene = levelScene
  }
  
  // MARK: GKState Life Cycle
  
  override func didEnter(from previousState: GKState?) {
    super.didEnter(from: previousState)
    
  }
  
  override func isValidNextState(_ stateClass: AnyClass) -> Bool {
    super.isValidNextState(stateClass)
    return stateClass is LevelSceneFailState.Type || stateClass is LevelSceneSuccessState.Type
  }
}
