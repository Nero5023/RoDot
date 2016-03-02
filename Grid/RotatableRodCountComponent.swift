//
//  RotatableRodCountComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/2.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class RotatableRodCountComponent: GKComponent {
  
  // MARK: Properties
  
  var rotatableRodCount: Int
  
  // MARK: Initializers
  
  init(rotatableRodCount: Int) {
    self.rotatableRodCount = rotatableRodCount
  }
}
