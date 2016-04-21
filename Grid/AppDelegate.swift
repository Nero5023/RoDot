//
//  AppDelegate.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/8.
//  Copyright © 2016年 Nero. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  lazy var coreDataStack = CoreDataStack()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    SceneManager.sharedInstance.managedContext = coreDataStack.context
    NSUserDefaults.standardUserDefaults().setBool(false, forKey: IsRecordingKey)
    NSUserDefaults.standardUserDefaults().registerDefaults([BackgroundMusicEabledKey: true, SoundEffertEabledKey: true])
    NSUserDefaults.standardUserDefaults().registerDefaults([LikedLevelIdsKey: [Int]()])
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
    
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
      let webURL = userActivity.webpageURL!
      
      present(URL: webURL)
      
    }
    
    return true
  }
  
  private func present(URL url: NSURL) -> Bool {
    if let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true), let host = components.host, let path = components.path, let pathComponents = NSURL(string: path)!.pathComponents {
      switch host {
      case "rodot.me", "www.rodot.me":
        if pathComponents.count == 3 {
          switch (pathComponents[0], pathComponents[1], pathComponents[2]) {
          case ("/", "level", let levelid):
            if let levelid = Int(levelid) where levelid > 0 {
              (window?.rootViewController as? UINavigationController)?.dismissViewControllerAnimated(false, completion: nil)
              HUD.show(.Progress)
              presentSceneWithLevelId(levelid)
              return true
            }
          default:
            return false
          }
        }
        
        return true
      default:
        return false
      }
    }
    return false
  }
  
  private func presentSceneWithLevelId(levelId: Int) {
    let task = Client.sharedInstance.getLevelDetail(levelId) { scene in
      dispatch_async(dispatch_get_main_queue()) {
        HUD.hide()
        SceneManager.sharedInstance.presentingView.presentScene(scene)
        SKTAudio.sharedInstance().playBackgroundMusic("background_play.mp3")
      }
    }
    Client.sharedInstance.setTimeOutDuration(10, taskToCancel: task)
  }

}

