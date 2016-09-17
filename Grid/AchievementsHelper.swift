//
//  AchievementsHelper.swift
//  Grid
//
//  Created by Nero Zuo on 16/4/11.
//  Copyright © 2016年 Nero. All rights reserved.
//

import Foundation
import GameKit

let RotateCountKey = "RotateCount"
let ShareCountKey = "ShareCount"

class  AchievementsHelper {
  static let Rotate10TimesAchievementId = "com.nero.rodot.rotate10times"
  static let Rotate50TimesAchievementId = "com.nero.rodot.rotate50times"
  static let Rotate100TimesAchievementId = "com.nero.rodot.rotate100times"
  static let Rotate500TimesAchievementId = "com.nero.rodot.rotate500times"
  
  static let ShareLevel10TimesAchievementId = "com.nero.rodot.sharelevel10times"
  static let ShareLevel50TimesAchievementId = "com.nero.rodot.sharelevel50times"
  static let ShareLevel100TimesAchievementId = "com.nero.rodot.sharelevel100times"
  
  class func rotateAchievements(_ roateCount: Int) -> [GKAchievement] {
    var totalRotateCountBefore: Int = 0
    if let count = UserDefaults.standard.object(forKey: RotateCountKey) as? Int {
      totalRotateCountBefore = count
    }
    let totalRotateCount = totalRotateCountBefore + roateCount
    var achievements = [GKAchievement]()

    if totalRotateCountBefore <= 10 {
      achievements.append(AchievementsHelper.getAchievement(totalRotateCount, targetCount: 10, identifier: AchievementsHelper.Rotate10TimesAchievementId))
    }
    if totalRotateCountBefore <= 50 {
      achievements.append(AchievementsHelper.getAchievement(totalRotateCount, targetCount: 50, identifier: AchievementsHelper.Rotate50TimesAchievementId))
    }
    if totalRotateCountBefore <= 100 {
      achievements.append(AchievementsHelper.getAchievement(totalRotateCount, targetCount: 100, identifier: AchievementsHelper.Rotate100TimesAchievementId))
    }
    if totalRotateCountBefore <= 500 {
      achievements.append(AchievementsHelper.getAchievement(totalRotateCount, targetCount: 500, identifier: AchievementsHelper.Rotate500TimesAchievementId))
    }
    UserDefaults.standard.set(totalRotateCount, forKey: RotateCountKey)
    return achievements
  }
  
  
  fileprivate class func getAchievement(_ count: Int ,targetCount: Int, identifier: String) -> GKAchievement {
    let percent = Double((Double(count)/Double(targetCount)) * 100)
    let achievement = GKAchievement(identifier: identifier, player: GKLocalPlayer())
    achievement.percentComplete = percent
//    print(achievement.percentComplete)
    achievement.showsCompletionBanner = true
    return achievement
  }
  
  class func shareAchievements() -> [GKAchievement] {
    var totalShareCount = 0
    if let count = UserDefaults.standard.object(forKey: ShareCountKey) as? Int {
      totalShareCount = count
    }
    totalShareCount += 1
    var achievements = [GKAchievement]()
    
    if totalShareCount - 1 <= 9 {
      achievements.append(AchievementsHelper.getAchievement(totalShareCount, targetCount: 10, identifier: AchievementsHelper.ShareLevel10TimesAchievementId))
    }
    
    if totalShareCount - 1 <= 49 {
      achievements.append(AchievementsHelper.getAchievement(totalShareCount, targetCount: 50, identifier: AchievementsHelper.ShareLevel50TimesAchievementId))
    }
    
    if totalShareCount - 1 <= 99 {
      achievements.append(AchievementsHelper.getAchievement(totalShareCount, targetCount: 100, identifier: AchievementsHelper.ShareLevel100TimesAchievementId))
    }
    
    UserDefaults.standard.set(totalShareCount, forKey: ShareCountKey)
    return achievements
  }
  
}
