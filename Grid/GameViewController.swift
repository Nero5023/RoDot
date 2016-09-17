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
      
      scene.startSceneDelegate = self
      
      let skView = self.view as! SKView
//      skView.showsFPS = true
//      skView.showsNodeCount = true
//     skView.showsPhysics = true
      
      /* Sprite Kit applies additional optimizations to improve rendering performance */
      skView.ignoresSiblingOrder = true
      
      /* Set the scale mode to scale to fit the window */
      scene.scaleMode = .aspectFill
      
      skView.presentScene(scene)
      
      SceneManager.sharedInstance.presentingView = skView
      SceneManager.sharedInstance.startScene = scene
      SceneManager.sharedInstance.presentingController = self
    }
//    
//    
//    if let scene = LevelScene(fileNamed: "test") {
//      let skView = self.view as! SKView
//      skView.showsFPS = true
//      skView.showsNodeCount = true
//      skView.ignoresSiblingOrder = true
//      scene.scaleMode = .AspectFill
//      
//      skView.presentScene(scene)
//    }
//
//    
  }
  
  override var shouldAutorotate : Bool {
    return true
  }
  
  override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  override var prefersStatusBarHidden : Bool {
    return true
  }
}

extension GameViewController: StartSceneDelegate {
  func didSelectMyDiysButton(_ scene: StartScene) {
//    print("in view controller")
    performSegue(withIdentifier: "presentdiyviewcontroller", sender: nil)
  }
  
  func didSelectMoreButton(_ scene: StartScene, buttonCenterPosition: CGPoint) {
    let floatMenuController = FloatingMenuController(fromPosition: buttonCenterPosition)
    floatMenuController.delegate = self
    let bgMusicImageName = SceneManager.sharedInstance.backgroundMusicEabled() ? "bgmusic" : "bgmusic_disabled"
    let soundEffertImageName = SceneManager.sharedInstance.soundEffertMusicEabled() ? "sound_effert" : "sound_effert_disabled"
    floatMenuController.buttonItems = [
      FloatingButton(image: UIImage(named: bgMusicImageName)),
      FloatingButton(image: UIImage(named: soundEffertImageName)),
//      FloatingButton(image: UIImage(named: "rate")),
      FloatingButton(image: UIImage(named: "gamecenter")),
    ]
    floatMenuController.labelTitles = [
      "Music",
      "Sound Effert",
//      "Rate",
      "GameCenter",
    ]
    present(floatMenuController, animated: true, completion: nil)
  }
}

extension GameViewController: FloatingMenueControllerDelegate {
  func floatingMenuController(_ controller: FloatingMenuController, didTapOnButton button: UIButton, atIndex index:Int) {
    switch index {
    case 0: // BackgroundMusci
      if SceneManager.sharedInstance.backgroundMusicEabled() {
        button.setImage(UIImage(named: "bgmusic_disabled"), for: UIControlState())
        SceneManager.sharedInstance.setBackgroundMuscicEabled(false)
      }else {
        button.setImage(UIImage(named: "bgmusic"), for: UIControlState())
        SceneManager.sharedInstance.setBackgroundMuscicEabled(true)
        SKTAudio.sharedInstance().playBackgroundMusic("background_music.wav")
      }
    case 1: // SoundEffert
      if SceneManager.sharedInstance.soundEffertMusicEabled() {
        button.setImage(UIImage(named: "sound_effert_disabled"), for: UIControlState())
        SceneManager.sharedInstance.setSoundEffertEabled(false)
      }else {
        button.setImage(UIImage(named: "sound_effert"), for: UIControlState())
        SceneManager.sharedInstance.setSoundEffertEabled(true)
      }
    case 2: //Gamecenter
//      controller.delegate
      controller.dismiss(animated: true) {
        GameKitHelper.shareInstance.showGKGameCenterViewController(self)
      }
    default:
      break
    }
    SKTAudio.sharedInstance().playSoundEffect("button_click_5.wav")
  }
}
