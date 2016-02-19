//
//  ProtocolAndCommon.swift
//  Bubble
//
//  Created by Nero Zuo on 16/2/4.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
  static let None:      UInt32 = 0
  static let Rod:       UInt32 = 1
  static let PointNode: UInt32 = 1 << 1
  static let Edge:      UInt32 = 1 << 2
  static let Ball:      UInt32 = 1 << 3
}

protocol CustomNodeEvents {
  func didMoveToScene()
}

