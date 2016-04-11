//
//  LevelManager.swift
//  Grid
//
//  Created by Nero Zuo on 16/4/10.
//  Copyright © 2016年 Nero. All rights reserved.
//

import Foundation

struct LevelManager {
  
  struct Constants {
    
    static let ThemeLevelDic = "ThemeLevelDic"
    
    static let ThemesCount = 3
    static let Theme1 = "Theme1"
    static let Theme2 = "Theme2"
    static let Theme3 = "Theme3"
    
    
    static let TotalLevels = "TotalLevels"
    static let UnlockedLevels = "UnlockedLevels"
    
    static let Theme1Levels = 25
    static let Theme2Levels = 25
    static let Theme3Levels = 25
  }
  
  var themesInfo: [String: [String: Int]] {
    didSet {
      NSUserDefaults.standardUserDefaults().setObject(themesInfo, forKey: LevelManager.Constants.ThemeLevelDic)
    }
  }
  
  var theme1: [String: Int] {
    return self.themesInfo[LevelManager.Constants.Theme1]!
  }
  
  var theme2: [String: Int] {
    return self.themesInfo[LevelManager.Constants.Theme2]!
  }
  
  var theme3: [String: Int] {
    return self.themesInfo[LevelManager.Constants.Theme3]!
  }
  
  init() {
    if let info = NSUserDefaults.standardUserDefaults().dictionaryForKey(LevelManager.Constants.ThemeLevelDic) as? [String: [String: Int]]{
      self.themesInfo = info
    }else {
      var themesInfo: [String: [String: Int]] = [:]

      let theme1Info = [LevelManager.Constants.TotalLevels: LevelManager.Constants.Theme1Levels,
                        LevelManager.Constants.UnlockedLevels: 1]
      let theme2Info = [LevelManager.Constants.TotalLevels: LevelManager.Constants.Theme2Levels,
                        LevelManager.Constants.UnlockedLevels: 0]
      let theme3Info =  [LevelManager.Constants.TotalLevels: LevelManager.Constants.Theme3Levels,
                         LevelManager.Constants.UnlockedLevels: 0]

      themesInfo[LevelManager.Constants.Theme1] = theme1Info
      themesInfo[LevelManager.Constants.Theme2] = theme2Info
      themesInfo[LevelManager.Constants.Theme3] = theme3Info
      
      self.themesInfo = themesInfo
    }
    
  }
  
  
}