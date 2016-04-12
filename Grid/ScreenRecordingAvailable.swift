//
//  ScreenRecordingAvailable.swift
//  Grid
//
//  Created by Nero Zuo on 16/4/12.
//  Copyright © 2016年 Nero. All rights reserved.
//

import Foundation
import ReplayKit

protocol ScreenRecordingAvailable {
  var screenRecordingAvailable: Bool { get }
}

extension ScreenRecordingAvailable {
  var screenRecordingAvailable: Bool {
    return RPScreenRecorder.sharedRecorder().available
  }
}

let IsRecordingKey = "IsRecording"

protocol IsRecordingProtocol {
  func toggleRecord()
  var isRecording: Bool { get }
}

extension IsRecordingProtocol {
  var isRecording: Bool {
    return NSUserDefaults.standardUserDefaults().boolForKey(IsRecordingKey)
  }
  
  func toggleRecord() {
    let recording = NSUserDefaults.standardUserDefaults().boolForKey(IsRecordingKey)
    NSUserDefaults.standardUserDefaults().setBool(!recording, forKey: IsRecordingKey)
  }
}