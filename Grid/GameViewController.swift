//
//  GameViewController.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/8.
//  Copyright (c) 2016年 Nero. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let scene = StartScene(fileNamed: "StartScene") {
      //        if let scene = LevelEditorScene(fileNamed:"LevelEditor") {
      //      if let scene = LevelScene.level(1) {
      // Configure the view.
      
      
      let skView = self.view as! SKView
      skView.showsFPS = true
      skView.showsNodeCount = true
      // skView.showsPhysics = true
      
      /* Sprite Kit applies additional optimizations to improve rendering performance */
      skView.ignoresSiblingOrder = true
      
      /* Set the scale mode to scale to fit the window */
      scene.scaleMode = .AspectFill
      
      skView.presentScene(scene)
      
      SceneManager.sharedInstance.presentingView = skView
      SceneManager.sharedInstance.startScene = scene
    }
  }
  
  override func shouldAutorotate() -> Bool {
    return true
  }
  
  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
      return .AllButUpsideDown
    } else {
      return .All
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}

//extension GameViewController: StartSceneDelegate {
//  func didSelectLevelSelectButton(scene: StartScene, level: Int) {
//    
//    performSegueWithIdentifier("showlevel", sender: level)
//  }
//  
//  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    if let levelVC = segue.destinationViewController as? LevelViewController, level = sender as? Int {
//      levelVC.level = level
//    }
//  }
//}
