//
//  BasePointEntity.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/1.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

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
