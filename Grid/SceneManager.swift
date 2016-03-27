//
//  SceneManager.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/26.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

final class SceneManager {
  
  // MARK: Propreties
  
  static let sharedInstance = SceneManager()
  
  var presentingView: SKView!
  
  var startScene: StartScene!
  
  func showLevelScene(level: Int) {
    let levelScene = LevelScene.level(level)
    levelScene?.scaleMode = .AspectFill
    presentingView.presentScene(levelScene)
  }
  
  func backToStartScene() {
    presentingView.presentScene(startScene)
  }
}
