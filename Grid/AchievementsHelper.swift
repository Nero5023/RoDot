//
//  AchievementsHelper.swift
//  Grid
//
//  Created by Nero Zuo on 16/4/11.
//  Copyright © 2016年 Nero. All rights reserved.
//

import Foundation
import GameKit

private let RotateCountKey = "RotateCount"

class  AchievementsHelper {
  static let Rotate10TimesAchievementId = "com.nero.rodot.rotate10times"
  static let Rotate50TimesAchievementId = "com.nero.rodot.rotate50times"
  static let Rotate100TimesAchievementId = "com.nero.rodot.rotate100times"
  static let Rotate500TimesAchievementId = "com.nero.rodot.rotate500times"
  
  class func rotateAchievements(roateCount: Int) -> [GKAchievement] {
    var totalRotateCount: Int = 0
    if let count = NSUserDefaults.standardUserDefaults().objectForKey(RotateCountKey) as? Int {
      totalRotateCount = count
    }
    totalRotateCount += roateCount
    var achievements = [GKAchievement]()
    achievements.reserveCapacity(4)
    achievements.append(AchievementsHelper.getRotateAchievement(totalRotateCount, targetRotateCount: 10, identifier: AchievementsHelper.Rotate10TimesAchievementId))
    achievements.append(AchievementsHelper.getRotateAchievement(totalRotateCount, targetRotateCount: 50, identifier: AchievementsHelper.Rotate50TimesAchievementId))
    achievements.append(AchievementsHelper.getRotateAchievement(totalRotateCount, targetRotateCount: 100, identifier: AchievementsHelper.Rotate100TimesAchievementId))
    achievements.append(AchievementsHelper.getRotateAchievement(totalRotateCount, targetRotateCount: 500, identifier: AchievementsHelper.Rotate500TimesAchievementId))
    NSUserDefaults.standardUserDefaults().setObject(totalRotateCount, forKey: RotateCountKey)
    return achievements
  }
  
  private class func getRotateAchievement(rotateCount: Int ,targetRotateCount: Int, identifier: String) -> GKAchievement {
    let percent = Double((Double(rotateCount)/Double(targetRotateCount)) * 100)
    let rotateAchievement = GKAchievement(identifier: identifier, player: GKLocalPlayer())
    rotateAchievement.percentComplete = percent
    rotateAchievement.showsCompletionBanner = true
    return rotateAchievement
  }
}