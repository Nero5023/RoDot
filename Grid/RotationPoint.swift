//
//  RotationPoint.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/24.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class RotationPoint: GKEntity {
  // Mark: properties
  
  // Mark: Initializers
  
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
    
    let relateComponent = RelateComponent()
    addComponent(relateComponent)
    
    let intelligenceComponent = IntelligenceComponent(states: [
      PointCheckingState(entity: self),
      PointUnlockedState(entity: self),
      PointLockedState(entity: self),
      PointRotatingState(entity: self)
    ])
    addComponent(intelligenceComponent)
    
    let detectComponent = DetectComponent()
    addComponent(detectComponent)
    
    let moveComponent = MoveComponent()
    addComponent(moveComponent)
    
  }
}
