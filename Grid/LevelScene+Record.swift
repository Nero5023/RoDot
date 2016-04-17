//
//  LevelScene+Record.swift
//  Grid
//
//  Created by Nero Zuo on 16/4/12.
//  Copyright © 2016年 Nero. All rights reserved.
//

import Foundation
import ReplayKit
import SpriteKit

extension LevelScene: ScreenRecordingAvailable, IsRecordingProtocol {
  
  
  func addRecordButton() {
    guard screenRecordingAvailable else { return }
    
    let recordButton = SKButtonNode(imageNameNormal: isRecording ? "recordingbutton" : "recordbutton", selected: "recordbutton_selected", disabled: "recordbutton_selected")
    recordButton.position = CGPoint(x: 1536-300-120, y: 1950)
    recordButton.name = "record"
    recordButton.zPosition = overlayNode.zPosition
    overlayNode.addChild(recordButton)
    recordButton.actionTouchUpInside = { [unowned self] in
      if self.isRecording {
        self.stopRecording(recordButton)
      }else {
//        recordButton.texture = SKTexture(imageNamed: "recordbutton_selected")
        recordButton.isEnabled = false
        self.startRecording(recordButton)
      }
    }
    recordButton.alpha = 0
    recordButton.runAction(SKAction.fadeInWithDuration(0.66))
  }
  
  func startRecording(button: SKButtonNode) {
    guard screenRecordingAvailable else { return }
    let sharedRecorder = RPScreenRecorder.sharedRecorder()
    sharedRecorder.delegate = self
    sharedRecorder.startRecordingWithMicrophoneEnabled(true) { error in
      if let error = error {
        dispatch_async(dispatch_get_main_queue()) {
//          HUD.flash(HUDContentType.LabeledError(title: "Error happened", subtitle: error.localizedDescription), delay: 1.3, completion: nil)
          print("sharedRecorder error: \(error.localizedDescription)")
          button.texture = SKTexture(imageNamed: "recordbutton")
          button.isEnabled = true
        }
        return
      }
      let soundReord = SKAction.playSoundFileNamed("record.wav", waitForCompletion: false)
      button.runAction(soundReord)
      self.toggleRecord()
      button.isEnabled = true
      button.texture = SKTexture(imageNamed: "recordingbutton")
    }
  }
  
  func stopRecording(button: SKButtonNode) {
    let sharedRecorder = RPScreenRecorder.sharedRecorder()
    sharedRecorder.stopRecordingWithHandler { previewViewController, error in
      if let error = error {
        dispatch_async(dispatch_get_main_queue()) {
          HUD.flash(HUDContentType.LabeledError(title: "Error happened", subtitle: error.localizedDescription), delay: 1.3, completion: nil)
          button.texture = SKTexture(imageNamed: "recordbutton")
        }
        return
      }
      if let previewViewController = previewViewController {
        previewViewController.previewControllerDelegate = self
        self.toggleRecord()
        button.texture = SKTexture(imageNamed: "recordbutton")
        SceneManager.sharedInstance.presentingController.presentViewController(previewViewController, animated: true, completion: nil)
      }
    }
  }
}

extension LevelScene: RPScreenRecorderDelegate {
  
}

extension LevelScene: RPPreviewViewControllerDelegate {
  func previewControllerDidFinish(previewController: RPPreviewViewController) {
    dispatch_async(dispatch_get_main_queue()) {
      SceneManager.sharedInstance.presentingController.dismissViewControllerAnimated(true, completion: self.stopRecordingCompletionHandler)
    }
    
  }
}
