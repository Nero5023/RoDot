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

        NotificationCenter.default.post(name: Notification.Name(rawValue: PresentAuthenticationViewController), object: self)
      }else if error == nil {
        self.gameCenterEnaled = true
      }
      
    }
  }
  
  func reportAchievements(_ achievements: [GKAchievement], errorHandler: ((NSError?)->Void)? = nil) {
    guard gameCenterEnaled else {
      return
    }
    GKAchievement.report(achievements, withCompletionHandler: errorHandler as! ((Error?) -> Void)?)
  }
  
  func reportScore(_ score: Int64, forLeaderBoardId leaderBoardId: String, errorHandler: ((NSError?)->Void)? = nil) {
    guard gameCenterEnaled else { return }
    let gkSore = GKScore(leaderboardIdentifier: leaderBoardId)
    gkSore.value = score
    GKScore.report([gkSore], withCompletionHandler: errorHandler as! ((Error?) -> Void)?)
  }
  
}

extension GameKitHelper: GKGameCenterControllerDelegate {
  func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
    gameCenterViewController.dismiss(animated: true, completion: nil)
  }
  
  
  func showGKGameCenterViewController(_ viewController: UIViewController) {
    guard gameCenterEnaled else { return }
    
    let gameCenterViewController = GKGameCenterViewController()
    
    gameCenterViewController.gameCenterDelegate = self
    
    viewController.present(gameCenterViewController, animated: true, completion: nil)
  }
}

