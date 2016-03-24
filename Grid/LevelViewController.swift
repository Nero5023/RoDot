//
//  LevelViewController.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/24.
//  Copyright © 2016年 Nero. All rights reserved.
//


import UIKit
import SpriteKit

class LevelViewController: UIViewController {
  
  var level: Int?
  
  override func viewDidLoad() {
    super.viewDidLoad()
      if let scene = LevelScene.level(level!) {
      // Configure the view.
        scene.levelSceneDelegate = self
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        //            skView.showsPhysics = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
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

extension LevelViewController: LevelSceneDelegate {
  func didSelectBackButton(scene: LevelScene) {
    navigationController?.popViewControllerAnimated(false)
  }
}
