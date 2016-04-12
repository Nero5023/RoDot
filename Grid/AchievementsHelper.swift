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
private let ShareCountKey = "ShareCount"

class  AchievementsHelper {
  static let Rotate10TimesAchievementId = "com.nero.rodot.rotate10times"
  static let Rotate50TimesAchievementId = "com.nero.rodot.rotate50times"
  static let Rotate100TimesAchievementId = "com.nero.rodot.rotate100times"
  static let Rotate500TimesAchievementId = "com.nero.rodot.rotate500times"
  
  static let ShareLevel10TimesAchievementId = "com.nero.rodot.sharelevel10times"
  static let ShareLevel50TimesAchievementId = "com.nero.rodot.sharelevel50times"
  static let ShareLevel100TimesAchievementId = "com.nero.rodot.sharelevel100times"
  
  class func rotateAchievements(roateCount: Int) -> [GKAchievement] {
    var totalRotateCount: Int = 0
    if let count = NSUserDefaults.standardUserDefaults().objectForKey(RotateCountKey) as? Int {
      totalRotateCount = count
    }
    totalRotateCount += roateCount
    var achievements = [GKAchievement]()
    achievements.reserveCapacity(4)
    achievements.append(AchievementsHelper.getAchievement(totalRotateCount, targetCount: 10, identifier: AchievementsHelper.Rotate10TimesAchievementId))
    achievements.append(AchievementsHelper.getAchievement(totalRotateCount, targetCount: 50, identifier: AchievementsHelper.Rotate50TimesAchievementId))
    achievements.append(AchievementsHelper.getAchievement(totalRotateCount, targetCount: 100, identifier: AchievementsHelper.Rotate100TimesAchievementId))
    achievements.append(AchievementsHelper.getAchievement(totalRotateCount, targetCount: 500, identifier: AchievementsHelper.Rotate500TimesAchievementId))
    NSUserDefaults.standardUserDefaults().setObject(totalRotateCount, forKey: RotateCountKey)
    return achievements
  }
  
  
  private class func getAchievement(count: Int ,targetCount: Int, identifier: String) -> GKAchievement {
    let percent = Double((Double(count)/Double(targetCount)) * 100)
    let achievement = GKAchievement(identifier: identifier, player: GKLocalPlayer())
    achievement.percentComplete = percent
    print(achievement.percentComplete)
    achievement.showsCompletionBanner = true
    return achievement
  }
  
  class func shareAchievements() -> [GKAchievement] {
    var totalShareCount = 0
    if let count = NSUserDefaults.standardUserDefaults().objectForKey(ShareCountKey) as? Int {
      totalShareCount = count
    }
    totalShareCount += 1
    var achievements = [GKAchievement]()
    achievements.reserveCapacity(3)
    achievements.append(AchievementsHelper.getAchievement(totalShareCount, targetCount: 10, identifier: AchievementsHelper.ShareLevel10TimesAchievementId))
    achievements.append(AchievementsHelper.getAchievement(totalShareCount, targetCount: 50, identifier: AchievementsHelper.ShareLevel50TimesAchievementId))
    achievements.append(AchievementsHelper.getAchievement(totalShareCount, targetCount: 100, identifier: AchievementsHelper.ShareLevel100TimesAchievementId))
    NSUserDefaults.standardUserDefaults().setObject(totalShareCount, forKey: ShareCountKey)
    return achievements
  }
  
}