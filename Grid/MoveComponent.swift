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
  
  var moveNode: SKSpriteNode?
  
  var lastTouchPosition: CGPoint?
  
  var centerPosition: CGPoint?
  
  let restAngularVelocity: CGFloat
  
  
  
  // MARK: Initializers
  
  override init() {
    restAngularVelocity = GameplayConfiguration.PhysicsFactors.restAngularVelocity
  }
  
  // MARK: GKComponent Life Cycle
  
  override func updateWithDeltaTime(seconds: NSTimeInterval) {
    super.updateWithDeltaTime(seconds)
    guard let moveNode = moveNode else { return }
    if isRotating == true && centerPosition != nil && lastTouchPosition != nil{
      let spritesLayer = moveNode.parent!
      let rodNode = renderComponent.node
      let angle = angleWith(moveNode.convertPoint(rodNode.position, toNode: spritesLayer) - centerPosition!, vector: lastTouchPosition! - centerPosition!)
      moveNode.physicsBody?.angularVelocity = angle * GameplayConfiguration.PhysicsFactors.compoundangularVelocityFactor
      
      
    }
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
      SKAction.rotateByAngle(angleToRotate, duration: NSTimeInterval(abs(angleToRotate)/restAngularVelocity)),
      SKAction.runBlock({ [unowned self] in
        // In the didSimulatePhysics will do do the block below
        (self.renderComponent.node.scene as! LevelScene).restRotatingCompletionBlock = {
          [unowned self] in
            self.entity?.componentForClass(RelateComponent.self)?.updateStateSurroundCenter()
            self.renderComponent.node.scene?.physicsWorld.removeAllJoints()
        }
        completion()
        
        })
      ])
    renderComponent.node.runAction(SKAction.afterDelay(0.1, performAction: action))
  }
  
  // MARK: Convenience Methods
  
  func angleWith(lastVector: CGPoint, vector: CGPoint) -> CGFloat {
    let oldAngle = atan2(lastVector.y, lastVector.x) - π/2
    let newAngle = atan2(vector.y, vector.x) - π/2
    return shortestAngleBetween(oldAngle, angle2: newAngle)
  }
  
  
}
