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
    return RPScreenRecorder.shared().isAvailable
  }
}

let IsRecordingKey = "IsRecording"

protocol IsRecordingProtocol {
  func toggleRecord()
  var isRecording: Bool { get }
}

extension IsRecordingProtocol {
  var isRecording: Bool {
    return UserDefaults.standard.bool(forKey: IsRecordingKey)
  }
  
  func toggleRecord() {
    let recording = UserDefaults.standard.bool(forKey: IsRecordingKey)
    UserDefaults.standard.set(!recording, forKey: IsRecordingKey)
  }
}
