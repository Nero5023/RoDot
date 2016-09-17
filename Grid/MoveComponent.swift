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
    guard let renderComponent = entity?.component(ofType: RenderComponent.self) else {
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
  
  // Used to fix the rod is stucked
  var afterDelayRestRotationBlock: (()->())?
  
  // MARK: Initializers
  
  override init() {
    restAngularVelocity = GameplayConfiguration.PhysicsFactors.restAngularVelocity
    restLinverVelocity = GameplayConfiguration.PhysicsFactors.restLinerVelocity
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: GKComponent Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    guard let moveNode = moveNode else { return }
    if let centerPosition = centerPosition, let lastTouchPosition = lastTouchPosition , isTranslating == false {
      let spritesLayer = moveNode.parent!
      let rodNode = renderComponent.node
      let angle = angleWith(moveNode.convert(rodNode.position, to: spritesLayer) - centerPosition, vector: lastTouchPosition - centerPosition)
      var angularVelocity: CGFloat = angle
      guard let centerNode = getCenterNode() else { return }
      if isRotating {
        if let clockwiseComponent = centerNode.entity.component(ofType: ClockwiseComponent.self) {
          angularVelocity = clockwiseComponent.calculateAngularVelocity(angularVelocity)
          if angularVelocity == 0 {
            moveNode.physicsBody?.allowsRotation = false
          }else {
            moveNode.physicsBody?.allowsRotation = true
          }
        }
        moveNode.physicsBody?.angularVelocity = angularVelocity * GameplayConfiguration.PhysicsFactors.compoundangularVelocityFactor
      }else { // for resting
//        if afterDelayRestRotationBlock == nil {
//          afterDelayRestRotationBlock = self.restRotationWithSKAction
//          delay(2) {
//            if let afterDelayRestRotationBlock = self.afterDelayRestRotationBlock {
//              afterDelayRestRotationBlock()
//            }
//          }
//        }
        
        angularVelocity = min(0.4, abs(angularVelocity)) * angularVelocity.sign()
//        print(angularVelocity)
        angularVelocity = max(0.2, abs(angularVelocity)) * angularVelocity.sign()
//        angularVelocity
        moveNode.physicsBody?.angularVelocity = angularVelocity * 5
        
        if abs(angle) < 0.04 {
          self.restRotationWithSKAction()
        }
      }
      lastAngle = angle
    }
    
    if isTranslating == true && centerPosition != nil && lastTouchPosition != nil {
      if let orientationComponent = entity?.component(ofType: OrientationComponent.self) {
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
        moveNode.physicsBody?.isDynamic = true
//        moveNode.physicsBody?.angularVelocity = 0
        moveNode.physicsBody?.allowsRotation = false

        moveNode.physicsBody?.velocity = CGVector(point: (lastTouchPosition! - moveNode.position) * tag * 10 )
      }
    }
  }
  
  func restRotationWithSKAction() {
    guard moveNode != nil && centerPosition != nil && lastTouchPosition != nil  else { return }
    let centerNode = getCenterNode()
    self.centerPosition = nil
    self.lastTouchPosition = nil
    self.moveNode = nil
    centerNode!.entity.component(ofType: RelateComponent.self)?.decompound()
    centerNode!.entity.component(ofType: MoveComponent.self)?.restRotation()
    afterDelayRestRotationBlock = nil
  }
  
  func getCenterNode() -> EntityNode? {
    for node in moveNode!.nodes(at: centerPosition!) where node is EntityNode {
      return node as? EntityNode
    }
    return nil
  }
  
  
  // This method is for the point node
  // After the rotating, rest the state of the relating nodes
  func restRotation() {
    (renderComponent.node.scene as? LevelScene)?.isResting = true
    SKTAudio.sharedInstance().playSoundEffect("close_lock_2.wav", withVolume: 0.33)
    let angle = renderComponent.node.zRotation.truncatingRemainder(dividingBy: (π/2.0))
    let angleToRotate: CGFloat
    if abs(angle) < π/4.0 {
      angleToRotate = -angle
    }else {
      angleToRotate = (π/2-abs(angle))*angle.sign()
    }
    let action = SKAction.sequence([
//      SKAction.rotateByAngle(angleToRotate, duration: NSTimeInterval(abs(angleToRotate)/restAngularVelocity)),
      SKAction.rotate(byAngle: angleToRotate, duration: 0.1),
//      SKAction.rotateByAngle(angleToRotate, duration: abs(Double(angleToRotate))/0.3),
      SKAction.run({ [unowned self] in
        // In the didSimulatePhysics will do do the block below
        (self.renderComponent.node.scene as! LevelScene).restRotatingCompletionBlock = {
          [unowned self] in
            self.renderComponent.node.scene?.physicsWorld.removeAllJoints()
            self.entity?.component(ofType: RelateComponent.self)?.updateStateSurroundCenter()
        }
        
        })
      ])
    action.timingMode = .easeInEaseOut
    renderComponent.node.run(SKAction.afterDelay(0.0, performAction: action))
  }
  
  func setTargetRestPosition() {
    guard let moveNode = moveNode else { return }
    if isRotating == false && centerPosition != nil && lastTouchPosition != nil{
      (renderComponent.node.scene as? LevelScene)?.isResting = true
      let rodNode = renderComponent.node
      let spritesLayer = moveNode.parent!
      var vector = moveNode.convert(rodNode.position, to: spritesLayer) - centerPosition!
      if abs(vector.x) > abs(vector.y) {
        vector = CGPoint(x: vector.x, y: 0)
      }else {
        vector = CGPoint(x: 0, y: vector.y)
      }
      
      lastTouchPosition = centerPosition! + vector
    }
    
  }
  
  func restTranslation(_ completion: @escaping () -> ()) {
    (renderComponent.node.scene as? LevelScene)?.isResting = true
    let targetPositon = getRestTargetPosition()
    renderComponent.node.physicsBody?.velocity = CGVector.zero
    guard let centerNode = renderComponent.node.parent?.atPoint(centerPosition!) as? EntityNode else {
      fatalError("The node at centerPositon is EntityNode")
    }
    let distanceToMove = targetPositon.distanceTo(renderComponent.node.position)
    SKTAudio.sharedInstance().playSoundEffect("close_lock_2.wav", withVolume: 0.33)
    let action = SKAction.sequence([
      SKAction.move(to: targetPositon, duration: TimeInterval(distanceToMove/restLinverVelocity)),
      SKAction.run({ [unowned self] in
        self.renderComponent.node.physicsBody?.isDynamic = false
        self.renderComponent.node.physicsBody?.allowsRotation = true
        (self.renderComponent.node.scene as? LevelScene)?.isResting = false
        centerNode.entity?.component(ofType: RelateComponent.self)?.updateStateSurroundCenter()
        completion()
        })
      ])
    renderComponent.node.run(action)    
  }
  
  // MARK: Convenience Methods
  
  func angleWith(_ lastVector: CGPoint, vector: CGPoint) -> CGFloat {
    let oldAngle = atan2(lastVector.y, lastVector.x) - π/2
    let newAngle = atan2(vector.y, vector.x) - π/2
    return shortestAngleBetween(oldAngle, angle2: newAngle)
  }
  
  func getRestTargetPosition() -> CGPoint {
    let distanceToTarget = GameplayConfiguration.Rod.height/2 + GameplayConfiguration.RotationPoint.radius
    guard let orientationComponent = entity?.component(ofType: OrientationComponent.self) else {
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

public func delay(_ delay:Double, closure:@escaping ()->()) {
  DispatchQueue.main.asyncAfter(
    deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
