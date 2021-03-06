//
//  Rod.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/24.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class Rod: GKEntity {
  
  // MARK: Properties
  
  
  // MARK: Initializers
  
  init(renderNode: SKSpriteNode) {
    super.init()
    
    let renderComponent = RenderComponent(entity: self, renderNode: renderNode)
    addComponent(renderComponent)
    
    let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: GameplayConfiguration.Rod.physizeBodyWidth, height: renderComponent.node.size.height - 2))
    physicsBody.affectedByGravity = false
    physicsBody.isDynamic = false
    
    let physicsComponent = PhysicsComponent(physicsBody:physicsBody, colliderType: GameplayConfiguration.Rod.collider)
    addComponent(physicsComponent)
    
    renderComponent.node.physicsBody = physicsComponent.physicsBody
    renderComponent.node.zPosition = GameplayConfiguration.Rod.zPosition
    
    let orientationComponent = OrientationComponent()
    orientationComponent.zRotation = renderComponent.node.zRotation
    addComponent(orientationComponent)
    
    let relateComponent = RelateComponent()
    addComponent(relateComponent)
    
    let detectComponent = DetectComponent()
    addComponent(detectComponent)
    
    let inputComponent = InputComponent()
    addComponent(inputComponent)
    
    let moveComponent = MoveComponent()
    addComponent(moveComponent)
    
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
}
