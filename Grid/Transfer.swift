//
//  Transfer.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/8.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class Transfer: GKEntity {
  // MARK: Properties
  
  
  // MARK: Initializers
  
  init(renderNode: SKSpriteNode) {
    super.init()
    
    let renderComponent = RenderComponent(entity: self, renderNode: renderNode)
    addComponent(renderComponent)
    
    let physicsBody = SKPhysicsBody(circleOfRadius: GameplayConfiguration.Transfer.phybodyRadius)
    physicsBody.affectedByGravity = false
    physicsBody.dynamic = false
    
    let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: GameplayConfiguration.Transfer.collider)
    addComponent(physicsComponent)
    
    renderComponent.node.physicsBody = physicsComponent.physicsBody
    renderComponent.node.zPosition = GameplayConfiguration.Transfer.zPosition
    
    let transferComponent = TransferComponent(renderNodeName: renderComponent.node.name!)
    addComponent(transferComponent)
    
  }
}
