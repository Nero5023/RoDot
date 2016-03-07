//
//  RelateComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/27.
//  Copyright © 2016年 Nero. All rights reserved.
//

// This Component is used to update the nodes around the node

import SpriteKit
import GameplayKit

class RelateComponent: GKComponent {
  
  // MARK: Properties
  
  var relateNodes: Set<EntityNode> = []
  
  var compound: SKSpriteNode?
  
  var renderComponent: RenderComponent {
    guard let renderComponent = entity?.componentForClass(RenderComponent.self) else {
      fatalError("A RelateComponent's entity must have a RenderComponent")
    }
    return renderComponent
  }
  
  // MARK: Actions
  
  func updateRelatedNodes() {
    relateNodes.removeAll()
    let renderNode = renderComponent.node
    let detectDistance = GameplayConfiguration.Rod.height/2.0 + GameplayConfiguration.RotationPoint.radius
    let allDirections = MoveDirection.allDirections
    for direction in allDirections {
      if let relateNode = detectNode(renderNode, inDirection: direction, detectDistance: detectDistance) as? EntityNode {
        if relateNode.entity.componentForClass(RelateComponent.self) != nil {
          relateNodes.insert(relateNode)
        }
      }
    }
  }
  
  // This is for point node, Convenience method
  // According to the center node to check state around it
  func updateStateSurroundCenter() {
    let detectDistance = GameplayConfiguration.Rod.height + GameplayConfiguration.RotationPoint.radius*2.0
    let allDirections = MoveDirection.allDirections
    for direction in allDirections {
      if let relateNode = detectNode(renderComponent.node, inDirection: direction, detectDistance: detectDistance) as? EntityNode {
        if  let stateMachine = relateNode.entity.componentForClass(IntelligenceComponent.self)?.stateMachine {
          stateMachine.enterState(PointCheckingState)
        }
      }
    }
    for entityNode in relateNodes {
      entityNode.entity.componentForClass(RelateComponent.self)?.updateRelatedNodes()
      entityNode.entity.componentForClass(OrientationComponent.self)?.zRotation = entityNode.zRotation
      entityNode.physicsBody!.dynamic = false
    }
    entity?.componentForClass(IntelligenceComponent.self)?.stateMachine.enterState(PointUnlockedState)
  }
  
  // This method is for Point entity
  // Used to make compound
  func makeCompoundNode() -> (SKSpriteNode, CGPoint) {
    let centerNode = renderComponent.node
    let centerPosition = centerNode.position
    let spritesLayer = centerNode.parent!
    let compound = SKSpriteNode()
    var bodies = [SKPhysicsBody]()
    centerNode.removeFromParent()
    centerNode.physicsBody = nil
    compound.addChild(centerNode)
    for node in relateNodes {
      node.removeFromParent()
      node.physicsBody = nil
      compound.addChild(node)
      if let orientationComponent = node.entity.componentForClass(OrientationComponent.self) {
        if orientationComponent.direction == .vertical {
          bodies.append(SKPhysicsBody(rectangleOfSize: CGSize(width: GameplayConfiguration.Rod.physizeBodyWidth, height: node.size.height - 8), center: node.position))
        }else {
          bodies.append(SKPhysicsBody(rectangleOfSize: CGSize(width: node.size.height - 8, height: GameplayConfiguration.Rod.physizeBodyWidth), center: node.position))
        }
      }
    }
    
    
    bodies.append(SKPhysicsBody(circleOfRadius: centerNode.size.width/2, center: centerNode.position))
    compound.physicsBody = SKPhysicsBody(bodies: bodies)
    compound.physicsBody!.categoryBitMask = PhysicsCategory.Rod
    compound.physicsBody!.collisionBitMask = PhysicsCategory.Ball
    spritesLayer.addChild(compound)
    
    let pinJoint = SKPhysicsJointPin.jointWithBodyA(compound.physicsBody!, bodyB: compound.scene!.physicsBody!, anchor: centerPosition)
    pinJoint.frictionTorque = GameplayConfiguration.PhysicsFactors.pinJointFrictionTorque
    pinJoint.rotationSpeed =  GameplayConfiguration.PhysicsFactors.pinJointRotationSpeed
    compound.scene!.physicsWorld.addJoint(pinJoint)
    self.compound = compound
    
    return (compound, centerPosition)
   
  }
  
  // This method is for Point entity
  // Used to decompound
  
  func decompound() {
    guard let compound = compound else { return }
    compound.scene!.physicsWorld.removeAllJoints()
    let spritesLayer = compound.parent!
    let compoundZRotation = compound.zRotation
    for node in compound.children {
      if let node = node as? EntityNode {
        node.removeFromParent()
        node.position = compound.convertPoint(node.position, toNode: spritesLayer)
        node.zRotation += compoundZRotation
        spritesLayer.addChild(node)
      }
    }
    compound.removeFromParent()
    self.compound = nil
    renderComponent.node.physicsBody = entity?.componentForClass(PhysicsComponent.self)?.physicsBody
    for node in relateNodes {
      node.physicsBody = node.entity.componentForClass(PhysicsComponent.self)?.physicsBody
      let fixJoint = SKPhysicsJointFixed.jointWithBodyA(node.physicsBody!, bodyB: renderComponent.node.physicsBody!, anchor: node.scene!.convertPoint(renderComponent.node.position, fromNode: node.parent!))
      node.physicsBody!.dynamic = true
      node.scene!.physicsWorld.addJoint(fixJoint)
    }
  }
  
  

  
  
}
