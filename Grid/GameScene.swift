//
//  GameScene.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/8.
//  Copyright (c) 2016年 Nero. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
  
  var gridLines = [SKSpriteNode]()
  var touchedLine: SKSpriteNode?
  var lastTouchedPosition: CGPoint?
  var anchorNode: SKSpriteNode!
  
  var compound: SKSpriteNode!
  
  var gridGraph = GridGraph()
  
  override func didMoveToView(view: SKView) {
    
    let maxAspectRatio: CGFloat = 16.0/9.0
    let maxAspectRatioWidth = size.height / maxAspectRatio
    
    let playableMargin: CGFloat = (size.width - maxAspectRatioWidth)/2
    let playableRect = CGRect(x: playableMargin, y: 0, width: size.width - playableMargin*2, height: size.height)
    physicsBody = SKPhysicsBody(edgeLoopFromRect: playableRect)
    
    
    enumerateChildNodesWithName("//*", usingBlock: {node, _ in
      if let customNode = node as? CustomNodeEvents {
        customNode.didMoveToScene()
      }
    })
    
//    setUp()
   
  }
  
//  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//    for touch in touches {
//      let location = touch.locationInNode(self)
//      print(nodeAtPoint(location))
//      print(location)
////      for lineNode in gridLines {
//////        lineNode.frame.
////        if CGRectContainsPoint(lineNode.frame, location) {
////          touchedLine = lineNode
////          lastTouchedPosition = position
////          break
////        }
////      }
//      lastTouchedPosition = position
//      
//    }
//    
//    
////    gridLines.first?.runAction(SKAction.rotateByAngle(CGFloat(90).degreesToRadians(), duration: 0.5))
////    gridLines.first?.physicsBody.
//    
//    
//
//  }
//  
//  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
//    guard let lastTouchedPosition = lastTouchedPosition else { return }
//    let position = touches.first?.locationInNode(self)
//
//    
//    let angle = angleWith(CGVector(point: lastTouchedPosition - anchorNode.position), vector: CGVector(point: position! - anchorNode.position))
//    
//    self.lastTouchedPosition = position
//    print(angle)
//    if abs(angle) > 1 {
//      return
//    }
//    
//    self.anchorNode.runAction(SKAction.rotateByAngle(angle, duration: 0.2))
//  }
//  
//  func angleWith(lastVector: CGVector, vector: CGVector) -> CGFloat {
//    let oldAngle = atan2(lastVector.dy, lastVector.dx) - π/2
//    let newAngle = atan2(vector.dy, vector.dx) - π/2
//    return shortestAngleBetween(oldAngle, angle2: newAngle)
//  }
//  
//  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//    lastTouchedPosition = nil
//  }
  
  override func update(currentTime: CFTimeInterval) {
    
  }
  
  func setUp() {
    anchorNode = SKSpriteNode(color: UIColor.blackColor(), size: CGSize(width: 22, height: 22))
    anchorNode.position = CGPoint(x: size.width/2, y: size.height/2)
    addChild(anchorNode)
    
        anchorNode.physicsBody = SKPhysicsBody(circleOfRadius: anchorNode.size.width/2)
        anchorNode.physicsBody?.affectedByGravity = false
        anchorNode.physicsBody?.dynamic = false
    
    var physicBodies = [SKPhysicsBody]()
    
    for i in 0 ..< 4 {
      let lineNode = SKSpriteNode(imageNamed: "rectangle.png")
      
      lineNode.anchorPoint = CGPoint(x: 0.5, y: 0)
      
      lineNode.zRotation = CGFloat(90).degreesToRadians() * CGFloat(i)
      
      switch i {
      case 0:
        lineNode.position = CGPoint(x: self.size.width/2, y: self.size.height/2 + lineNode.size.width/2)
      case 1:
        lineNode.position = CGPoint(x: self.size.width/2 - lineNode.size.width/2, y: self.size.height/2)
      case 2:
        lineNode.position = CGPoint(x: self.size.width/2, y: self.size.height/2 - lineNode.size.width/2)
      default:
        lineNode.position = CGPoint(x: self.size.width/2 + lineNode.size.width/2, y: self.size.height/2)
      }
      
      physicBodies.append(SKPhysicsBody(rectangleOfSize: lineNode.size, center: CGPoint(x: 0, y: lineNode.size.height/2)))
      lineNode.physicsBody = SKPhysicsBody(rectangleOfSize: lineNode.size, center: CGPoint(x: 0, y: lineNode.size.height/2))
      lineNode.physicsBody?.affectedByGravity = false
//      lineNode.physicsBody?.dynamic = false
      
      addChild(lineNode)
//      let pinJoint = SKPhysicsJointPin.jointWithBodyA(lineNode.physicsBody!, bodyB: self.physicsBody!, anchor: CGPoint(x: size.width/2, y: size.height/2))
////      let fixedJoint = SKPhysicsJointFixed.jointWithBodyA(lineNode.physicsBody!, bodyB: anchorNode.physicsBody!, anchor: CGPoint(x: size.width/2, y: size.height/2))
//      self.physicsWorld.addJoint(pinJoint)
      
      gridLines.append(lineNode)
      //
      //        gridLines.z
    }
    
//    for i in 0 ..< 4 {
//      let fixedJoint = SKPhysicsJointFixed.jointWithBodyA(gridLines[i].physicsBody!, bodyB: gridLines[(i+1)%4].physicsBody!, anchor: CGPoint(x: size.width/2, y: size.height/2))
//      physicsWorld.addJoint(fixedJoint)
//    }
    
    for i in 0 ..< 4 {
      let fixedJoint = SKPhysicsJointFixed.jointWithBodyA(gridLines[i].physicsBody!, bodyB: anchorNode.physicsBody!, anchor: CGPoint(x: size.width/2, y: size.height/2))
      physicsWorld.addJoint(fixedJoint)
    }
    
//    compound = SKSpriteNode()
//    compound.physicsBody = SKPhysicsBody(bodies: physicBodies)
//    
//    compound.zRotation = CGFloat(45).degreesToRadians()
//    compound.position = CGPoint(x: size.width/2, y: size.height/2)
//    addChild(compound)
    
//    anchorNode.runAction(SKAction.rotateByAngle(CGFloat(90).degreesToRadians(), duration: 2))
//    anchorNode.afterDelay(3, runBlock: {
//      self.anchorNode.runAction(SKAction.rotateByAngle(CGFloat(45).degreesToRadians(), duration: 0))
//    })
    
    let ball = SKSpriteNode(color: UIColor.blackColor(), size: CGSize(width: 50, height: 50))
    ball.position = CGPoint(x: size.width/2 - 100, y: size.height/2 + 100)
    ball.physicsBody = SKPhysicsBody(circleOfRadius: 25)
//    ball.physicsBody?.mass = 1000000
    addChild(ball)
  }
  
  override func didSimulatePhysics() {
    
  }
  
  
  
  
  func setUpView() {
    var physicBodies = [SKPhysicsBody]()
    let tempNode = SKSpriteNode(imageNamed: "rectangle.png")
    let height = tempNode.size.height * 2 + tempNode.size.width
    compound = SKSpriteNode(color: UIColor.clearColor(), size: CGSize(width: height, height: height))
    
    compound.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
    
    for i in 0 ..< 4 {
      let lineNode = SKSpriteNode(imageNamed: "rectangle.png")
      lineNode.anchorPoint = CGPoint(x: 0.5, y: 0)
      lineNode.zRotation = CGFloat(90).degreesToRadians() * CGFloat(i)
      
      switch i {
      case 0:
        lineNode.position = CGPoint(x: 0, y:  lineNode.size.width/2)
      case 1:
        lineNode.position = CGPoint(x: 0 - lineNode.size.width/2, y: 0)
      case 2:
        lineNode.position = CGPoint(x: 0, y: 0 - lineNode.size.width/2)
      default:
        lineNode.position = CGPoint(x: lineNode.size.width/2, y: 0)
      }
      
//      if i == 1 {
//        
//        physicBodies.append(SKPhysicsBody(rectangleOfSize: lineNode.size, center: CGPoint(x: 0, y: lineNode.size.height/2)))
//      }
      lineNode.physicsBody = SKPhysicsBody(rectangleOfSize: lineNode.size, center: CGPoint(x: 0, y: lineNode.size.height/2))
      lineNode.physicsBody?.affectedByGravity = false
//      physicBodies.append(lineNode.physicsBody!)
//      lineNode.physicsBody = nil
      compound.addChild(lineNode)
      gridLines.append(lineNode)
    }
    compound.physicsBody = SKPhysicsBody(bodies: physicBodies)
    compound.physicsBody?.affectedByGravity = false
    addChild(compound)
    
    for x in physicBodies {
      print(x.accessibilityFrame)
    }
    
  }
}


