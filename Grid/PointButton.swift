//
//  PointButton.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/19.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit

class PointButton: SKButtonNode {
  var type: PointNodeType?
  var nextNodeName: String?
  
  
  func addDetail() {
    guard let type = type else {
      fatalError("When addDetail the type must not be nil!")
    }
    switch type {
    case .staticNode, .translationNode:
      return
    case .restrictedNode(let rotateableRodCount, let isClockwise, let rotateCount):
      if let rotateableRodCount = rotateableRodCount {
        SceneManager.sharedInstance.addBubbles(self, rotatableRodCount: rotateableRodCount)
      }
      if let rotateCount = rotateCount {
        SceneManager.sharedInstance.addRotateCountNodes(self, rotateCount: rotateCount)
      }
      if let isClockwise = isClockwise {
        SceneManager.sharedInstance.animationBubble(self, isClockwise: isClockwise)
      }
    }
  }
  
  func removeDetail() {
    for node in self.children {
      node.removeFromParent()
    }
  }
}
