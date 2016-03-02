//
//  RenderComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/24.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class EntityNode: SKSpriteNode {
  weak var entity: GKEntity!
}


class RenderComponent: GKComponent {
  // Mark: Properties
  
  let node = EntityNode()
  
  //MARK: Initializers
  
  init(entity: GKEntity, renderNode: SKSpriteNode) {
    node.entity = entity
    // Copy the properties for the entityNode
    node.texture = renderNode.texture
    node.name = renderNode.name
    node.size = renderNode.size
    node.zRotation = renderNode.zRotation
    node.position = renderNode.position
    node.color = renderNode.color
  }
}
