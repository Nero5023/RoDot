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
  static let Transfer:  UInt32 = 1 << 4
  static let IceBall:   UInt32 = 1 << 5
  static let Distance:  UInt32 = 1 << 6
}

protocol CustomNodeEvents {
  func didMoveToScene()
}

func detectNode(centerNode: SKNode, inDirection direction: MoveDirection, detectDistance:CGFloat) -> SKNode? {
  let targetPosition = CGPoint(
    x: centerNode.position.x + CGFloat(direction.tag.0)*detectDistance,
    y: centerNode.position.y + CGFloat(direction.tag.1)*detectDistance)
  for node in centerNode.parent!.nodesAtPoint(targetPosition) {
    if let node = node as? EntityNode {
      return node
    }
  }
  // Maybe wrong
  return centerNode.parent?.nodeAtPoint(targetPosition)
}