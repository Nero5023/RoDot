//
//  LeaderboardHelper.swift
//  Grid
//
//  Created by Nero Zuo on 16/4/19.
//  Copyright © 2016年 Nero. All rights reserved.
//

import Foundation

class LeaderboardHelper {
  static let MostShareTimesLeaderboardId = "com.nero.rodot.mostsharetimes"
  static let MostRotateTimesLeaderboardId = "com.nero.rodot.mostrotatetimes"
  
  class func reportMostShareTimesLeaderboard() {
    let shareTimes = NSUserDefaults.standardUserDefaults().integerForKey(ShareCountKey)
    GameKitHelper.shareInstance.reportScore(Int64(shareTimes), forLeaderBoardId: LeaderboardHelper.MostShareTimesLeaderboardId)
  }
  
  class func reportMostRotateTimesToLeaderboard() {
    let rotateTimes = NSUserDefaults.standardUserDefaults().integerForKey(RotateCountKey)
    GameKitHelper.shareInstance.reportScore(Int64(rotateTimes), forLeaderBoardId: LeaderboardHelper.MostRotateTimesLeaderboardId)
  }
}