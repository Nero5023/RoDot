//
//  PointNodeType.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/14.
//  Copyright © 2016年 Nero. All rights reserved.
//


import SpriteKit
import GameplayKit


// MARK: Regular Expressions

protocol RegularExpressionMatchable {
  func match(pattern: String, options: NSRegularExpressionOptions) -> Bool
}

extension String: RegularExpressionMatchable {
  func match(pattern: String, options: NSRegularExpressionOptions) -> Bool {
    let regex = try! NSRegularExpression(pattern: pattern, options: options)
    return regex.numberOfMatchesInString(self, options: [], range: NSMakeRange(0, self.utf16.count)) != 0
  }
}

infix operator =~ { associativity left precedence 130 }
func =~<T: RegularExpressionMatchable>(left: T, right: String) -> Bool {
  return left.match(right, options: [])
}


// MARK: PointNodeType

enum PointNodeType {
  case staticNode
  case translationNode
  case restrictedNode(Int?, Bool?, Int?) //rotatanleRodCount, isClockwise, RotateCount
  
  // MARK: Initializers
  
  init(nodeName: String?) {
    guard let nodeName = nodeName else {
      fatalError("The Point Node must have a name.")
    }
    switch nodeName {
    case "static":
      self = .staticNode
      return
    case "translation":
      self = .translationNode
      return
    case "normal":
      self = .restrictedNode(nil, nil, nil)
      return
    default:
      break
    }
    
    let nodeProperties = PointNodeType.roteatableRodCountIsClockwiseRotateCount(nodeName)
    self = .restrictedNode(nodeProperties.0, nodeProperties.1, nodeProperties.2)
  }
  
  static func roteatableRodCountIsClockwiseRotateCount(nodeName: String) -> (Int?, Bool?, Int?) {
    var rotatableRodCount: Int? = nil
    var rotateCount: Int? = nil
    var isClockwise: Bool? = nil
    if let _rotatableRodCount = Int(String(nodeName.characters.first!)) {
      if case 1...4 = _rotatableRodCount {
        rotatableRodCount = _rotatableRodCount
      }else {
        fatalError("RotatableRodCount must in range [1,4]")
      }
    }
    
    if let _rotateCount = Int(String(nodeName.characters.last!)) {
      if case 1 ... 9 = _rotateCount {
        rotateCount = _rotateCount
      }else {
        fatalError("RotatableRodCount must in range [1,9]")
      }
    }
    
    if nodeName =~ "cw" {
      isClockwise = true
    }else if nodeName =~ "ac" {
      isClockwise = false
    }else if nodeName =~ "normal"{
      isClockwise = nil
    }else {
      fatalError("The nodeName didn't much the pattern")
    }
    
    return (rotatableRodCount, isClockwise, rotateCount)
  }
  
  func pointEntity(node: RotationPointNode) -> BasePointEntity {
    var entity: BasePointEntity?
    switch self {
    case .staticNode:
      entity = StaticPoint(renderNode: node)
    case .translationNode:
      entity = TranslationPoint(renderNode: node)
    case .restrictedNode(let rotateableRodCount, let isClockwise, let rotateCount):
      if rotateableRodCount == nil && isClockwise == nil {
        entity = RotationPoint(renderNode: node, rotateCount: rotateCount)
        break
      }
      if let rotateableRodCount = rotateableRodCount where isClockwise == nil {
        entity = RestrictedRotationPoint(renderNode: node, rotatableRodCount: rotateableRodCount, rotateCount: rotateCount)
        break
      }
      if let isClockwise = isClockwise where rotateableRodCount == nil {
        entity = ClockwiseRotationPoint(renderNode: node, isClockwise: isClockwise, rotateCount: rotateCount)
      }
      if let isClockwise = isClockwise, rotateableRodCount = rotateableRodCount {
        entity = ClockwiseRescritedRPoint(renderNode: node, rotatableRodCount: rotateableRodCount, isClockwise: isClockwise, rotateCount: rotateCount)
      }
    }
    if let entity = entity {
      return entity
    }else {
      fatalError("The entity doesn't Initializers")
    }
  }
}