//
//  RodNode.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/10.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

let kDidFinshRotationgNotification = "kDidFinshRotationgNotification"


class RodNode: SKSpriteNode, CustomNodeEvents {

//  MARK: Property
  let MIN_MOVE_DISTANCE: CGFloat = 0
  
  // The direction of the rodNode, vertical, horizontal
  enum Direction {
    case vertical
    case horizontal
  }
  
  var pointNodes = Set<RotationPointNode>() {
    didSet {
      if pointNodes.count == 0 {
        userInteractionEnabled = false
      }else {
        userInteractionEnabled = true
      }
    }
  }
  
  var firstTouchPoint: CGPoint?
  var lastTouchPoint: CGPoint?
  var rotatingNode: RotationPointNode?
  
  var direction: Direction?
  
  var isRotating = false
  
  private var upOrLeftNode: RotationPointNode?
  private var downOrRightNode: RotationPointNode?
  
//  MARK:CustomNodeEvents methods
  func didMoveToScene() {
    physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: size.width, height: size.height-8))
    physicsBody?.affectedByGravity = false
    physicsBody?.dynamic = false
//    physicsBody?.usesPreciseCollisionDetection = true
  }
  
  
//MARK:  Touch events
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    print(pointNodes.count)
    print("self:\(position)")
    for node in pointNodes {
      print(node.position)
    }
    guard pointNodes.count != 0 && touches.count == 1 else { return }
    
    firstTouchPoint = touches.first!.locationInNode(self.parent!)
    if abs(position.x - pointNodes.first!.position.x) < pointNodes.first!.size.width {
      direction = Direction.vertical
      for node in pointNodes {
        if node.position.y > position.y {
          upOrLeftNode = node
        }else {
          downOrRightNode = node
        }
      }
    }else {
      direction = Direction.horizontal
      for node in pointNodes {
        if node.position.x < position.x {
          upOrLeftNode = node
        }else {
          downOrRightNode = node
        }
      }
    }
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let firstTouchPoint = firstTouchPoint, direction = direction else { return }
    
    if !isRotating {
      let vector = touches.first!.locationInNode(self.parent!) - firstTouchPoint
      if abs(vector.x) > MIN_MOVE_DISTANCE && abs(vector.y) > MIN_MOVE_DISTANCE {
        if direction == .vertical {
          if vector.y > 0 {
            upOrLeftNode?.state.enterState(Rotating)
          }else {
            downOrRightNode?.state.enterState(Rotating)
          }
        }else {
          if vector.x < 0 {
            upOrLeftNode?.state.enterState(Rotating)
          }else {
            downOrRightNode?.state.enterState(Rotating)
          }
        }
        isRotating = true
        lastTouchPoint = firstTouchPoint
        if let node = upOrLeftNode {
          if node.state.currentState! is Rotating {
            rotatingNode = node
          }
        }
        // may have to be changed
        if let node = downOrRightNode {
          if node.state.currentState! is Rotating {
            rotatingNode = node
          }
        }
      }
    }else {
      //rotating
      if let pointNode = rotatingNode {
        let touchPosition = touches.first!.locationInNode(parent!)
        let angle = angleWith(CGVector(point: lastTouchPoint! - pointNode.position), vector: CGVector(point: touchPosition - pointNode.position))
//        pointNode.runAction(SKAction.rotateByAngle(angle, duration: 0.2))
//        pointNode.zRotation += angle
        physicsBody?.applyImpulse(CGVector(dx: 100, dy: 100))
        lastTouchPoint = touchPosition
      }
    }
  }
  
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    resetRotation()
  }
  
  
  override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    resetRotation()
  }
  
  override func touchesEstimatedPropertiesUpdated(touches: Set<NSObject>) {
    
  }

  func resetRotation() {
    lastTouchPoint = nil
    firstTouchPoint = nil
    upOrLeftNode = nil
    downOrRightNode = nil
    isRotating = false
    
    // Make sure the rotating the 90
    // May have a bug here
    if let rotatingNode = rotatingNode {
      let angle = rotatingNode.zRotation % (π/2.0)
      if abs(angle) <  π/4.0{
        let action = SKAction.sequence([SKAction.rotateByAngle(-angle, duration: 0.2),
          SKAction.runBlock({ [unowned self] in
            print(rotatingNode.zRotation.radiansToDegrees())
            //            The next two methods will do in the do in the observer
            //            rotatingNode.scene?.physicsWorld.removeAllJoints()
            //            self.updateRelatedPointNodeState()
            NSNotificationCenter.defaultCenter().postNotificationName(kDidFinshRotationgNotification, object: self)
            })
          ])
        rotatingNode.runAction(SKAction.afterDelay(0.1, performAction: action))
      }else{
        let action = SKAction.sequence([SKAction.rotateByAngle((π/2-abs(angle))*angle.sign(), duration: 0.2),
          SKAction.runBlock({ [unowned self] in
            print(rotatingNode.zRotation.radiansToDegrees())
            //            rotatingNode.scene?.physicsWorld.removeAllJoints()
            //            self.updateRelatedPointNodeState()
            NSNotificationCenter.defaultCenter().postNotificationName(kDidFinshRotationgNotification, object: self)
            })
          ])
        rotatingNode.runAction(SKAction.afterDelay(0.1, performAction: action))
      }
    }
  }
  
  
  func angleWith(lastVector: CGVector, vector: CGVector) -> CGFloat {
    let oldAngle = atan2(lastVector.dy, lastVector.dx) - π/2
    let newAngle = atan2(vector.dy, vector.dx) - π/2
    return shortestAngleBetween(oldAngle, angle2: newAngle)
  }
  
  // Update the nodes that around the rotated nodes
  func updateRelatedPointNodeState() {
    guard let rotatingNode = rotatingNode else { return }
    let tags = [(1, 0), (0, 1), (0, -1), (-1, 0)]
    let distance = max(self.size.width, self.size.height) + rotatingNode.size.width
    for tag in tags {
      let targetPosition = CGPoint(
        x: rotatingNode.position.x + CGFloat(tag.0)*distance,
        y: rotatingNode.position.y + CGFloat(tag.1)*distance)
      if let pointNode = rotatingNode.parent!.nodeAtPoint(targetPosition) as? RotationPointNode {
        pointNode.state.enterState(Checking)
      }
    }
    rotatingNode.state.enterState(Checking)
    // In the game scene file didSimulatePhysics I set the rotatingNode to nil
    //self.rotatingNode = nil
  }
  
}
