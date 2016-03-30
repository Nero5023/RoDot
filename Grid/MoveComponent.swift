//
//  MoveComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/25.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class MoveComponent: GKComponent {
  
  // MARK: Properties
  
  var renderComponent: RenderComponent {
    guard let renderComponent = entity?.componentForClass(RenderComponent.self) else {
      fatalError("A MoveComponent's entity must have a RenderComponent ")
    }
    return renderComponent
  }
  
  var isRotating = false
  
  var isTranslating = false
  
  var moveNode: SKSpriteNode?
  
  var lastTouchPosition: CGPoint?
  
  var centerPosition: CGPoint?
  
  let restAngularVelocity: CGFloat
  let restLinverVelocity: CGFloat
  
  var lastAngle: CGFloat = 0
  
  // MARK: Initializers
  
  override init() {
    restAngularVelocity = GameplayConfiguration.PhysicsFactors.restAngularVelocity
    restLinverVelocity = GameplayConfiguration.PhysicsFactors.restLinerVelocity
  }
  
  // MARK: GKComponent Life Cycle
  
  override func updateWithDeltaTime(seconds: NSTimeInterval) {
    super.updateWithDeltaTime(seconds)
    guard let moveNode = moveNode else { return }
    if isRotating == true && centerPosition != nil && lastTouchPosition != nil{
      let spritesLayer = moveNode.parent!
      let rodNode = renderComponent.node
      let angle = angleWith(moveNode.convertPoint(rodNode.position, toNode: spritesLayer) - centerPosition!, vector: lastTouchPosition! - centerPosition!)
      var angularVelocity: CGFloat = angle
      
      if let centerNode = getCenterNode() {
        if let clockwiseComponent = centerNode.entity.componentForClass(ClockwiseComponent.self) {
          angularVelocity = clockwiseComponent.calculateAngularVelocity(angularVelocity)
          if angularVelocity == 0 {
            moveNode.physicsBody?.allowsRotation = false
          }else {
            moveNode.physicsBody?.allowsRotation = true
          }
        }
      }
      
      
      moveNode.physicsBody?.angularVelocity = angularVelocity * GameplayConfiguration.PhysicsFactors.compoundangularVelocityFactor
      lastAngle = angle
    }
    if isTranslating == true && centerPosition != nil && lastTouchPosition != nil {
      if let orientationComponent = entity?.componentForClass(OrientationComponent.self) {
        var tag: CGPoint
        if orientationComponent.direction == HVDirection.horizontal {
          tag = CGPoint(x: 1, y: 0)
        }else {
          tag = CGPoint(x: 0, y: 1)
        }
        let lTargetPositon = centerPosition! + CGPoint(x: 22 + 105, y: 22 + 105)
        let sTargetPositon = centerPosition! + CGPoint(x: -22 - 105, y: -22 - 105)
        lastTouchPosition = CGPoint(x: max(min(lastTouchPosition!.x, lTargetPositon.x), sTargetPositon.x),
                              y: max(min(lastTouchPosition!.y, lTargetPositon.y), sTargetPositon.y))
        moveNode.physicsBody?.dynamic = true
//        moveNode.physicsBody?.angularVelocity = 0
        moveNode.physicsBody?.allowsRotation = false

        moveNode.physicsBody?.velocity = CGVector(point: (lastTouchPosition! - moveNode.position) * tag * 10 )
      }
    }
  }
  
  func getCenterNode() -> EntityNode? {
    for node in moveNode!.nodesAtPoint(centerPosition!) where node is EntityNode {
      return node as? EntityNode
    }
    return nil
  }
  
  
  // This method is for the point node
  // After the rotating, rest the state of the relating nodes
  func restRotation(completion: () -> ()) {
    (renderComponent.node.scene as? LevelScene)?.isResting = true
    let angle = renderComponent.node.zRotation % (π/2.0)
    let angleToRotate: CGFloat
    if abs(angle) < π/4.0 {
      angleToRotate = -angle
    }else {
      angleToRotate = (π/2-abs(angle))*angle.sign()
    }
    let action = SKAction.sequence([
//      SKAction.rotateByAngle(angleToRotate, duration: NSTimeInterval(abs(angleToRotate)/restAngularVelocity)),
      SKAction.rotateByAngle(angleToRotate, duration: 0.33),
      SKAction.runBlock({ [unowned self] in
        // In the didSimulatePhysics will do do the block below
        (self.renderComponent.node.scene as! LevelScene).restRotatingCompletionBlock = {
          [unowned self] in
            self.renderComponent.node.scene?.physicsWorld.removeAllJoints()
          self.entity?.componentForClass(RelateComponent.self)?.updateStateSurroundCenter()
        }
        completion()
        
        })
      ])
    renderComponent.node.runAction(SKAction.afterDelay(0.1, performAction: action))
  }
  
  func restTranslation(completion: () -> ()) {
    (renderComponent.node.scene as? LevelScene)?.isResting = true
    let targetPositon = getRestTargetPosition()
    renderComponent.node.physicsBody?.velocity = CGVector.zero
    guard let centerNode = renderComponent.node.parent?.nodeAtPoint(centerPosition!) as? EntityNode else {
      fatalError("The node at centerPositon is EntityNode")
    }
    let distanceToMove = targetPositon.distanceTo(renderComponent.node.position)
    let action = SKAction.sequence([
      SKAction.moveTo(targetPositon, duration: NSTimeInterval(distanceToMove/restLinverVelocity)),
      SKAction.runBlock({ [unowned self] in
        self.renderComponent.node.physicsBody?.dynamic = false
        self.renderComponent.node.physicsBody?.allowsRotation = true
        (self.renderComponent.node.scene as? LevelScene)?.isResting = false
        centerNode.entity?.componentForClass(RelateComponent.self)?.updateStateSurroundCenter()
        completion()
        })
      ])
    renderComponent.node.runAction(action)    
  }
  
  // MARK: Convenience Methods
  
  func angleWith(lastVector: CGPoint, vector: CGPoint) -> CGFloat {
    let oldAngle = atan2(lastVector.y, lastVector.x) - π/2
    let newAngle = atan2(vector.y, vector.x) - π/2
    return shortestAngleBetween(oldAngle, angle2: newAngle)
  }
  
  func getRestTargetPosition() -> CGPoint {
    let distanceToTarget = GameplayConfiguration.Rod.height/2 + GameplayConfiguration.RotationPoint.radius
    guard let orientationComponent = entity?.componentForClass(OrientationComponent.self) else {
      fatalError("The node to rest translation must have a OrientationComponent.")
    }
    var targetPositon: CGPoint
    if orientationComponent.direction == HVDirection.horizontal {
      if renderComponent.node.position.x < centerPosition!.x {
        targetPositon = centerPosition! + CGPoint(x: -distanceToTarget , y: 0)
      }else {
        targetPositon = centerPosition! + CGPoint(x: distanceToTarget, y: 0)
      }
    }else {
      if renderComponent.node.position.y < centerPosition!.y {
        targetPositon = centerPosition! + CGPoint(x: 0, y: -distanceToTarget)
      }else {
        targetPositon = centerPosition! + CGPoint(x: 0, y: distanceToTarget)
      }
    }
    return targetPositon
  }


}
