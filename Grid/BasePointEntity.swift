//
//  BasePointEntity.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/1.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit


enum PointNodeType: Int {
  case staticNode = 0, restrictedNode1, restrictedNode2, restrictedNode3, restrictedNode4, normalNode
  
  // MARK: Initializers
  
  init(nodeName: String?) {
    guard let nodeName = nodeName else {
      fatalError("The point node doesn't have a name")
    }
    switch nodeName {
      case "static":
        self = .staticNode
      case "1":
        self = .restrictedNode1
      case "2":
        self = .restrictedNode2
      case "3":
        self = .restrictedNode3
      case "4":
        self = .restrictedNode4
      case "normal":
        self = .normalNode
      default:
        fatalError("Unknown pointNodeName: \(nodeName)")
    }
  }
}

/**
    This is the Bas entity for the Point Entity
*/

class BasePointEntity: GKEntity {
  
  // MARK: Initializers
  
  init(renderNode: SKSpriteNode) {
    super.init()
    
    let renderComponent = RenderComponent(entity: self, renderNode: renderNode)
    addComponent(renderComponent)
    
    let physicsBody = SKPhysicsBody(circleOfRadius: renderComponent.node.size.width/2.0)
    physicsBody.affectedByGravity = false
    physicsBody.dynamic = false
    let physicsComponent = PhysicsComponent(physicsBody:physicsBody, colliderType: GameplayConfiguration.RotationPoint.collider)
    addComponent(physicsComponent)
    
    renderComponent.node.physicsBody = physicsComponent.physicsBody
    renderComponent.node.zPosition = GameplayConfiguration.RotationPoint.zPositon
    
  }
  
}
