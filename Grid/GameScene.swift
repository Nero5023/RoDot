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
  
  var gridGraph = GridGraph()
  var isFinishRotation = false
  var rotatingRodNode: RodNode?
  
  var compound: SKSpriteNode?
  
  var targetZRotation: CGFloat = 0.0
  
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
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "finshRotation:", name: kDidFinshRotationgNotification, object: nil)
   
  }
  
  func finshRotation(notification: NSNotification) {
    if let rodNode = notification.object as? RodNode {
      isFinishRotation = true
      rodNode.updateRelatedPointNodeState()
      rotatingRodNode = rodNode
    }
  }
  
  

  
  override func update(currentTime: CFTimeInterval) {
    if let compound = compound, lastTouchedPosition = lastTouchedPosition {
//      compound.physicsBody?.applyImpulse(impulseVector, atPoint: compound.position)
//      compound.physicsBody?.applyAngularImpulse(1)
//      compound.physicsBody?.applyForce(impulseVector, atPoint: compound.position)
//      compound.physicsBody?.angularVelocity = impulseVector.length()/100
      let angle = angleWith(compound.convertPoint(rotatingRodNode!.position, toNode: self) - compound.convertPoint(rotatingRodNode!.rotatingNode!.position, toNode: self),
        vector: lastTouchedPosition - compound.convertPoint(rotatingRodNode!.rotatingNode!.position, toNode: self))
      compound.physicsBody?.angularVelocity = angle * 10
    }
    
//    if targetZRotation != 0 && targetZRotation != compound!.zRotation {
//      compound?.physicsBody?.angularVelocity = 10
//      print(targetZRotation - (compound?.zRotation)!)
//    }else if targetZRotation != 0 && targetZRotation == compound!.zRotation {
//      compound?.physicsBody?.angularVelocity = 0
//    }
    
    
  }
  
  func angleWith(lastVector: CGPoint, vector: CGPoint) -> CGFloat {
    let oldAngle = atan2(lastVector.y, lastVector.x) - π/2
    let newAngle = atan2(vector.y, vector.x) - π/2
    return shortestAngleBetween(oldAngle, angle2: newAngle)
  }
  
  override func didSimulatePhysics() {
    if isFinishRotation {
      if let rotatingPointNode = rotatingRodNode?.rotatingNode {
        gridGraph.setAllRelatedRodsDynamicWithRotationNode(rotatingPointNode)
        rotatingRodNode?.rotatingNode = nil
        rotatingRodNode = nil
      }
      physicsWorld.removeAllJoints()
      isFinishRotation = false
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    // locationInNode the self may be changed
    let touchLocation = touches.first!.locationInNode(self)
    if let rodNode = nodeAtPoint(touchLocation) as? RodNode {
      if rodNode.pointNodes.count != 0 {
        rodNode.setUpRotation(touches, withEvent: event)
        //TODO It's wrong here to set the rotatingRodNode
        rotatingRodNode = rodNode
      }
    }
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let rotatingRodNode = rotatingRodNode else { return }
    if let compound = compound {
      lastTouchedPosition = touches.first?.locationInNode(self)
    }else {
      rotatingRodNode.checkRotation(touches, withEvent: event)
      if rotatingRodNode.isRotating {
        addCompound()
      }
    }
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    restRotation()
//    rotatingRodNode?.resetRotation()
//    decompound()
//    rotatingRodNode = nil
//    compound = nil
  }
  
  func addCompound() {
    let centerPosition = rotatingRodNode!.rotatingNode!.position
    if let compound = gridGraph.makeCompoundNode(withPointNode: rotatingRodNode!.rotatingNode!) {
      //TODO:
      //Need to change self.physicsBody?
      addChild(compound)
      let pinJoint = SKPhysicsJointPin.jointWithBodyA(compound.physicsBody!, bodyB: physicsBody!, anchor: centerPosition)
      pinJoint.frictionTorque = 1
      pinJoint.rotationSpeed = 0.01
      physicsWorld.addJoint(pinJoint)
      self.compound = compound
    }
  }
  
  func decompound() {
    guard let compound = compound else { return }
    physicsWorld.removeAllJoints()
    let compoundZRotation = compound.zRotation
    for node in compound.children {
      if let node = node as? SKSpriteNode {
//        print(node.zRotation)
        
        node.removeFromParent()
        node.position = compound.convertPoint(node.position, toNode: self)
        node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: node.size.width, height: node.size.height-8), center: node.position)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.dynamic = false
        addChild(node)
        node.zRotation += compoundZRotation
//        print(node.zRotation)
        compound.physicsBody = nil
      }
    }
    
    //May be need to change
    enumerateChildNodesWithName("//*", usingBlock: {node, _ in
      if let customNode = node as? CustomNodeEvents {
        customNode.didMoveToScene()
      }
    })
  }
  
  func restRotation() {
    guard let rotatingRodNode = rotatingRodNode, compound = compound else { return }
    decompound()
    if let rotatingPointNode = rotatingRodNode.rotatingNode {
      gridGraph.attachJointFixToPointNode(rotatingPointNode, atScene: self)
      //?
//      rotatingRodNode.rest()
      let angle = rotatingPointNode.zRotation % (π/2.0)
      if abs(angle) <  π/4.0 {
        let action = SKAction.sequence([SKAction.rotateByAngle(-angle, duration: 0.4),
          SKAction.runBlock({ [unowned self] in
            self.finshRotation()
            })
          ])
        rotatingPointNode.runAction(SKAction.afterDelay(0.1, performAction: action))
      }else {
        let action = SKAction.sequence([SKAction.rotateByAngle((π/2-abs(angle))*angle.sign(), duration: 0.4),
          SKAction.runBlock({ [unowned self] in
            self.finshRotation()
            })
          ])
        rotatingPointNode.runAction(SKAction.afterDelay(0.1, performAction: action))
      }
    }
  }
  
  
  func finshRotation() {
    if let rodNode = rotatingRodNode {
      rodNode.rest()
      isFinishRotation = true
      rodNode.updateRelatedPointNodeState()
//      physicsWorld.removeAllJoints()
//      rotatingRodNode = nil
      compound = nil
    }
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: kDidFinshRotationgNotification, object: nil)
  }
  
}


