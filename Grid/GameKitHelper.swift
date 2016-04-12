//
//  GameKitHelper.swift
//  Grid
//
//  Created by Nero Zuo on 16/4/10.
//  Copyright © 2016年 Nero. All rights reserved.
//

import UIKit
import Foundation
import GameKit

let PresentAuthenticationViewController = "PresentAuthenticationViewController"

class GameKitHelper: NSObject {
  static let shareInstance = GameKitHelper()
  
  var authenticationViewController: UIViewController?
  var gameCenterEnaled = false
  
  func authenticateLocalPlayer() {
    let localPlayer = GKLocalPlayer()
    localPlayer.authenticateHandler = { (viewController, error) in
      if viewController != nil {
        self.authenticationViewController = viewController

        NSNotificationCenter.defaultCenter().postNotificationName(PresentAuthenticationViewController, object: self)
      }else if error == nil {
        self.gameCenterEnaled = true
      }
      
    }
  }
  
  func reportAchievements(achievements: [GKAchievement], errorHandler: ((NSError?)->Void)? = nil) {
    guard gameCenterEnaled else {
      return
    }
    GKAchievement.reportAchievements(achievements, withCompletionHandler: errorHandler)
  }
  
  func reportScore(score: Int64, forLeaderBoardId leaderBoardId: String, errorHandler: ((NSError?)->Void)? = nil) {
    guard gameCenterEnaled else { return }
    let gkSore = GKScore(leaderboardIdentifier: leaderBoardId)
    gkSore.value = score
    GKScore.reportScores([gkSore], withCompletionHandler: errorHandler)
  }
  
}
