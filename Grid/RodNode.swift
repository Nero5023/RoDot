//
//  RodNode.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/10.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit



class RodNode: SKSpriteNode, CustomNodeEvents {

  let MIN_MOVE_DISTANCE: CGFloat = 20
  
  
  enum Direction {
    case vertical
    case horizontal
  }
  
  var pointNodes = [RotationPointNode]() {
    
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
  
  func didMoveToScene() {
    physicsBody = SKPhysicsBody(rectangleOfSize: size)
    physicsBody?.affectedByGravity = false
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard pointNodes.count != 0 && touches.count == 1 else {
      
      return
    }
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
        // bug 要弄周围的几个rodnode也要变成dynamic
        // may be a lot of bugs
        lastTouchPoint = firstTouchPoint
      }
    }else {
      //rotating
//      let pointNode = upOrLeftNode?.state.currentState == Rotating ? upOrLeftNode : downOrRightNode

      if let node = upOrLeftNode {
        if node.state.currentState! is Rotating {
          rotatingNode = node
        }
      }else if let node = downOrRightNode {
        if node.state.currentState! is Rotating {
          rotatingNode = node
        }
      }
      
      if let pointNode = rotatingNode {
        let touchPosition = touches.first!.locationInNode(parent!)
        let angle = angleWith(CGVector(point: lastTouchPoint! - pointNode.position), vector: CGVector(point: touchPosition - pointNode.position))
//        pointNode.runAction(SKAction.rotateByAngle(angle, duration: 0.2))
        pointNode.zRotation += angle
        lastTouchPoint = touchPosition
      }
    }
  }
  
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
   
//    if let pointNode = rotatingNode {
//      let touchPosition = touches.first!.locationInNode(parent!)
//      let angle = angleWith(CGVector(point: lastTouchPoint! - pointNode.position), vector: CGVector(point: touchPosition - pointNode.position))
//      //        pointNode.runAction(SKAction.rotateByAngle(angle, duration: 0.2))
//      pointNode.zRotation += angle
//      lastTouchPoint = touchPosition
//    }
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
            rotatingNode.scene?.physicsWorld.removeAllJoints()
            self.updateRelatedPointNodeState()})
          ])
        rotatingNode.runAction(SKAction.afterDelay(0.3, performAction: action))
      }else{
        let action = SKAction.sequence([SKAction.rotateByAngle((π/2-abs(angle))*angle.sign(), duration: 0.2),
          SKAction.runBlock({ [unowned self] in
            rotatingNode.scene?.physicsWorld.removeAllJoints()
            self.updateRelatedPointNodeState()})
          ])
        rotatingNode.runAction(SKAction.afterDelay(0.3, performAction: action))
      }
    }
    
//    rotatingNode = nil
    
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
    self.rotatingNode = nil
  }
  
}
