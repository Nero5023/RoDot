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
  
  // This function is already implemente by the SKScene
  func childNodeWithName(name: String) -> SKNode?
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
    return hudNode
  }
  
  var overlayNode: SKNode {
    guard let overlayNode = childNodeWithName("Overlay") else {
      fatalError("The Secne conform the SceneLayerProtocol must have the node have Overlay")
    }
    return overlayNode
  }
  
  
  
}