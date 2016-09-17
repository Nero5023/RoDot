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
    recordButton.position = CGPoint(x: size.width - xMargin - 108 - 120, y: 1950)
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
    recordButton.run(SKAction.fadeIn(withDuration: 0.66))
  }
  
  func startRecording(_ button: SKButtonNode) {
    guard screenRecordingAvailable else { return }
    let sharedRecorder = RPScreenRecorder.shared()
    sharedRecorder.delegate = self
    sharedRecorder.startRecording(withMicrophoneEnabled: true) { error in
      if let error = error {
        DispatchQueue.main.async {
//          HUD.flash(HUDContentType.LabeledError(title: "Error happened", subtitle: error.localizedDescription), delay: 1.3, completion: nil)
          print("sharedRecorder error: \(error.localizedDescription)")
          button.texture = SKTexture(imageNamed: "recordbutton")
          button.isEnabled = true
        }
        return
      }
      SKTAudio.sharedInstance().playSoundEffect("record.wav")
      self.toggleRecord()
      button.isEnabled = true
      button.texture = SKTexture(imageNamed: "recordingbutton")
    }
  }
  
  func stopRecording(_ button: SKButtonNode) {
    let sharedRecorder = RPScreenRecorder.shared()
    sharedRecorder.stopRecording { previewViewController, error in
      if let error = error {
        DispatchQueue.main.async {
          HUD.flash(HUDContentType.labeledError(title: "Error happened", subtitle: error.localizedDescription), delay: 1.3, completion: nil)
          button.texture = SKTexture(imageNamed: "recordbutton")
        }
        return
      }
      if let previewViewController = previewViewController {
        previewViewController.previewControllerDelegate = self
        self.toggleRecord()
        button.texture = SKTexture(imageNamed: "recordbutton")
        SceneManager.sharedInstance.presentingController.present(previewViewController, animated: true, completion: nil)
      }
    }
  }
}

extension LevelScene: RPScreenRecorderDelegate {
  
}

extension LevelScene: RPPreviewViewControllerDelegate {
  func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
    DispatchQueue.main.async {
      SceneManager.sharedInstance.presentingController.dismiss(animated: true, completion: self.stopRecordingCompletionHandler)
    }
    
  }
}
