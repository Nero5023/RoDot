//
//  LevelManager.swift
//  Grid
//
//  Created by Nero Zuo on 16/4/10.
//  Copyright © 2016年 Nero. All rights reserved.
//

import Foundation

enum ThemeType: String {
  case Theme1 = "theme1"
  case Theme2 = "theme2"
  case Theme3 = "theme3"
  
  var themeNum: Int {
      switch self {
      case .Theme1:
        return 1
      case .Theme2:
        return 2
      case .Theme3:
        return 3
    }
  }
  
  static var allTypes: [ThemeType] = [.Theme1, .Theme2, .Theme3]
  
  var themeTotalLevels: Int {
    switch self {
    case .Theme1:
      return LevelManager.Constants.Theme1Levels
    case .Theme2:
      return LevelManager.Constants.Theme2Levels
    case .Theme3:
      return LevelManager.Constants.Theme3Levels
    }
  }
}

class LevelManager {
  
  static let shareInstance = LevelManager()
  
  struct Constants {
    
    static let ThemeLevelDic = "ThemeLevelDic"
    
    static let ThemesCount = 3
    
    static let Theme1 = ThemeType.Theme1.rawValue
    static let Theme2 = ThemeType.Theme2.rawValue
    static let Theme3 = ThemeType.Theme3.rawValue
    
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
  
//  let themeMap: [Int: [String: Int]]
  
  var theme1: [String: Int] {
    return self.themesInfo[LevelManager.Constants.Theme1]!
  }
  
  var theme2: [String: Int] {
    return self.themesInfo[LevelManager.Constants.Theme2]!
  }
  
  var theme3: [String: Int] {
    return self.themesInfo[LevelManager.Constants.Theme3]!
  }
  
  lazy var themeMap: [Int: [String: Int]] = {
    return [1: self.theme1, 2: self.theme2, 3: self.theme3]
  }()
  
  private init() {
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
  
  func passLevel(theme theme: ThemeType, level: Int) {
    guard  level > 0 && level <= themesInfo[theme.rawValue]![LevelManager.Constants.TotalLevels] else { return }
    if level == themesInfo[theme.rawValue]![LevelManager.Constants.UnlockedLevels]! {
      themesInfo[theme.rawValue]![LevelManager.Constants.UnlockedLevels] = level+1
    }
  }
  
  // Just for test user or me
  func passAllLevels() {
    themesInfo[ThemeType.Theme1.rawValue]![LevelManager.Constants.UnlockedLevels] = 25+1
    themesInfo[ThemeType.Theme2.rawValue]![LevelManager.Constants.UnlockedLevels] = 25+1
    themesInfo[ThemeType.Theme3.rawValue]![LevelManager.Constants.UnlockedLevels] = 25+1
  }
  
  func getUnlockLevels(themeType theme: ThemeType) -> Int {
    return themesInfo[theme.rawValue]![LevelManager.Constants.UnlockedLevels]!
  }
  
  func unLockTheme(theme: ThemeType) {
    guard getUnlockLevels(themeType: theme) == 0 else { return }
    themesInfo[theme.rawValue]![LevelManager.Constants.UnlockedLevels] = 1
    delay(2) {
      HUD.flash(.Label("You just have unlocked \(theme.rawValue)"), delay: 1.5)
    }
  }
  
  func themeEabled(theme: ThemeType) -> Bool {
    return getUnlockLevels(themeType: theme) != 0
  }
  
}