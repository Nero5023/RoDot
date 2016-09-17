//
//  SceneLayerProtocol.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/26.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit

// This Protocol is used to help the scene to point to the bgNode, spritesNode, hudNode, overlayNode

protocol SceneLayerProtocol {
  var bgNode: SKNode { get }
  var spritesNode: SKNode { get }
  var hudNode: SKNode { get }
  var overlayNode: SKNode { get }
  
  var playableMargin: CGFloat { get }
  var playableRect: CGRect { get }
  var backgroundRect: CGRect { get }
  var xMargin: CGFloat { get }
  
  // This function is already implemente by the SKScene
  func childNodeWithName(_ name: String) -> SKNode?
  var view: SKView? { get }
  var size: CGSize { get set }
}

extension SceneLayerProtocol {
  var bgNode: SKNode {
    guard let bgNode = childNodeWithName("Background") else {
      fatalError("The Secne conform the SceneLayerProtocol must have the node have Background")
    }
    return bgNode
  }
  
  var spritesNode: SKNode {
    guard let spritesNode = childNodeWithName("Sprites") else {
      fatalError("The Secne conform the SceneLayerProtocol must have the node named Sprites")
    }
    return spritesNode
  }

  var hudNode: SKNode {
    guard let hudNode = childNodeWithName("HUD") else {
      fatalError("The Secne conform the SceneLayerProtocol must have the node named HUD")
    }
    hudNode.zPosition = 500
    return hudNode
  }
  
  var overlayNode: SKNode {
    guard let overlayNode = childNodeWithName("Overlay") else {
      fatalError("The Secne conform the SceneLayerProtocol must have the node have Overlay")
    }
    return overlayNode
  }
  
  var playableMargin: CGFloat {
    let maxAspectRatio: CGFloat = 16.0/9.0
    let maxAspectRatioWidth = size.height / maxAspectRatio
    return (size.width - maxAspectRatioWidth)/2
  }
  
  var playableRect: CGRect {
    return CGRect(x: playableMargin, y: 0, width: size.width - playableMargin*2, height: size.height)
  }
  
  var backgroundRect: CGRect {
    let factor = view!.bounds.size.width/view!.bounds.size.height
    let backgroundRectWidth = factor * size.height
    let margin = (size.width - backgroundRectWidth) / 2.0
    return CGRect(origin: CGPoint(x: margin, y: 0), size: CGSize(width: backgroundRectWidth, height: size.height))
//    var backgroundRect = playableRect
//    var backgroundRect = playableRect
//    if view!.bounds.size.height/view!.bounds.size.width <= 1.5 { // not 16:9
//      backgroundRect = CGRect(origin: CGPoint.zero, size: size)
//    }
//    return backgroundRect
  }
  
  var xMargin: CGFloat {
    return backgroundRect.origin.x
  }
  
  
}
