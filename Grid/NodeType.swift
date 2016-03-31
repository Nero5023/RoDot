//
//  NodeType.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/31.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit

enum NodeType: String {
  case transfer = "transfer"
  case ball = "ball"
  case destination = "destination"
  case rod = "rod"
  case iceBall = "iceBall"
  case pointNode = "PointNode"
  
  
  init(nodeName: String?) {
    guard let nodeName = nodeName else {
      fatalError("The Node must have a name.")
    }
    if nodeName.hasPrefix("transfer") {
      self = .transfer
      return
    }
    switch nodeName {
    case "ball":
      self = .ball
      return
    case "destination":
      self = .destination
      return
    case "rod":
      self = .rod
      return
    case "iceBall":
      self = .iceBall
      return
    default:
      self = .pointNode
    }
  }
  
  func nodeType() -> SKSpriteNode.Type {
    
    switch self {
    case .transfer:
      return TransferNode.self
    case .ball:
      return BallNode.self
    case .destination:
      return DestinationNode.self
    case .rod:
      return RodNode.self
    case .iceBall:
      return IceBallNode.self
    case .pointNode:
      return RotationPointNode.self
    }
  }
  
}

