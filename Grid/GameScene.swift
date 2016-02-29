//
//  GameScene.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/8.
//  Copyright (c) 2016年 Nero. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  // MARK: Property
  var gridLines = [SKSpriteNode]()
  var touchedLine: SKSpriteNode?
  var lastTouchedPosition: CGPoint?
  var anchorNode: SKSpriteNode!
  
  var gridGraph = GridGraph.sharedInstance
  var isFinishRotation = false
  var isResting = false
  var rotatingRodNode: RodNode?
  
  var compound: SKSpriteNode?
  
  var targetZRotation: CGFloat = 0.0
  
  var bgNode = SKNode()
  var spritesNode = SKNode()
  var hudNode = SKNode()
  var overlayNode = SKNode()
  
  override func didMoveToView(view: SKView) {
    setUpScene()
    setUpNode()
    
    physicsWorld.contactDelegate = self
    
    enumerateChildNodesWithName("//*", usingBlock: {node, _ in
      if let customNode = node as? CustomNodeEvents {
        customNode.didMoveToScene()
      }
    })
    
  }
  
  //Set up nodes
  func setUpNode() {
    bgNode = childNodeWithName("Background")!
    spritesNode = childNodeWithName("Sprites")!
    hudNode = childNodeWithName("HUD")!
    overlayNode = childNodeWithName("Overlay")!
  }
  
  func setUpScene() {
    let maxAspectRatio: CGFloat = 16.0/9.0
    let maxAspectRatioWidth = size.height / maxAspectRatio
    
    let playableMargin: CGFloat = (size.width - maxAspectRatioWidth)/2
    let playableRect = CGRect(x: playableMargin, y: 0, width: size.width - playableMargin*2, height: size.height)
    physicsBody = SKPhysicsBody(edgeLoopFromRect: playableRect)
    physicsBody!.categoryBitMask = PhysicsCategory.Edge
    physicsBody!.collisionBitMask = PhysicsCategory.Ball
  }
  

  // MARK: Update
  override func update(currentTime: CFTimeInterval) {
    if let compound = compound, lastTouchedPosition = lastTouchedPosition {
      let angle = angleWith(compound.convertPoint(rotatingRodNode!.position, toNode: spritesNode) - compound.convertPoint(rotatingRodNode!.rotatingNode!.position, toNode: spritesNode),
        vector: lastTouchedPosition - compound.convertPoint(rotatingRodNode!.rotatingNode!.position, toNode: spritesNode))
      
      
      compound.physicsBody?.angularVelocity = angle * 10
    }
  }
  
  // The shorest angle between two vector
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
      isResting = false
      isFinishRotation = false
    }
  }
  
  //MARK: Touch event
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard isResting == false else { return }
    let touchLocation = touches.first!.locationInNode(spritesNode)
    if let rodNode = nodeAtPoint(touchLocation) as? RodNode {
      // Only rodNode have the pointNodes can rotate
      if rodNode.pointNodes.count != 0 {
        // 
        if rodNode.setUpRotation(touches, withEvent: event) {
          rotatingRodNode = rodNode
          rodNode.isRotating = false
        }
      }
    }
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard isResting == false else { return }
    // Check the if already reference to the rotatingRodNode
    guard let rotatingRodNode = rotatingRodNode else { return }
    
    // Check if compound the nodes
    if let _ = compound {
      lastTouchedPosition = touches.first?.locationInNode(spritesNode)
    }else {
      rotatingRodNode.checkRotation(touches, withEvent: event)
      if rotatingRodNode.isRotating {
        addCompound()
      }
    }
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard isResting == false else { return }
    // May can put it in the restRotation
//    isResting = true
    restRotation()
  }
  
  // Make compounds
  func addCompound() {
    guard let rotatingRodNode = rotatingRodNode, rotationPointNode = rotatingRodNode.rotatingNode
      else { return }
    let centerPosition = rotationPointNode.position
    if let compound = gridGraph.makeCompoundNode(withPointNode: rotationPointNode) {
      spritesNode.addChild(compound)
      let pinJoint = SKPhysicsJointPin.jointWithBodyA(compound.physicsBody!, bodyB: physicsBody!, anchor: centerPosition)
      pinJoint.frictionTorque = 1
      pinJoint.rotationSpeed = 0.01
      physicsWorld.addJoint(pinJoint)
      self.compound = compound
    }
  }
  
  // Decompound the compound node
  func decompound() {
    guard let compound = compound else { return }
    physicsWorld.removeAllJoints()
    let compoundZRotation = compound.zRotation
    var nodes = [SKNode]()
    for node in compound.children {
      if let node = node as? SKSpriteNode {
        node.removeFromParent()
        // Convert the node position to the self(may be changed to the overlay)
        node.position = compound.convertPoint(node.position, toNode: spritesNode)
        //Don't know why it doesn't work
        node.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 22, height: node.size.height-8), center: node.position)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.dynamic = false
        spritesNode.addChild(node)
        node.zRotation += compoundZRotation
        compound.physicsBody = nil
        
        nodes.append(node)
      }
    }
    
    for node in gridGraph.getAllRotatingNodes(withPointNode: rotatingRodNode!.rotatingNode!) {
      if let node = node as? CustomNodeEvents {
        node.didMoveToScene()
      }
    }
//    for node in nodes {
//      if let node = node as? CustomNodeEvents {
//        node.didMoveToScene()
//      }
//    }
    
    for node in nodes {
      if let rod = node as? RodNode {
        let fixJoint = SKPhysicsJointFixed.jointWithBodyA(rod.physicsBody!, bodyB: rotatingRodNode!.rotatingNode!.physicsBody!,
          anchor: self.convertPoint(rotatingRodNode!.rotatingNode!.position, fromNode: rod.parent!))
        rod.physicsBody!.dynamic = true
        physicsWorld.addJoint(fixJoint)
      }
//      let fixJoint = SKPhysicsJointFixed.jointWithBodyA(rod.physicsBody!, bodyB: node.physicsBody!, anchor: scene.convertPoint(node.position, fromNode: node.parent!))
//      rod.physicsBody!.dynamic = true
//      scene.physicsWorld.addJoint(fixJoint)
    }
    
  }
  
  func restRotation() {
    guard let rotatingRodNode = rotatingRodNode,  _ = compound else { return }
    if let rotatingPointNode = rotatingRodNode.rotatingNode {
      decompound()
//      gridGraph.attachJointFixToPointNode(rotatingPointNode, atScene: self)
      //Rest the nodes position
      let angle = rotatingPointNode.zRotation % (π/2.0)
      isResting = true
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
      // In the didSimulatePhysics rest other properties
      isFinishRotation = true
      rodNode.updateRelatedPointNodeState()
      compound = nil
      lastTouchedPosition = nil
    }
  }
  
  
  // MARK: Physics Contact Delegate
  
  func didBeginContact(contact: SKPhysicsContact) {
    let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    
    if collision == PhysicsCategory.Ball | PhysicsCategory.Transfer {
      let transfer = contact.bodyA.categoryBitMask == PhysicsCategory.Transfer ? contact.bodyA.node : contact.bodyB.node
      let ball = contact.bodyA.categoryBitMask == PhysicsCategory.Ball ? contact.bodyA.node : contact.bodyB.node
      ball!.removeFromParent()
      enumerateChildNodesWithName("//\(transfer!.name!)") { [unowned self] transferNode, _ in
        if transferNode != transfer {
          ball!.position = transferNode.position
          transferNode.parent!.addChild(ball!)
          ball!.physicsBody!.categoryBitMask = PhysicsCategory.None
          transferNode.physicsBody!.categoryBitMask = PhysicsCategory.None
          self.afterDelay(1.5, runBlock: {
            ball!.physicsBody!.categoryBitMask = PhysicsCategory.Ball
            transferNode.physicsBody!.categoryBitMask = PhysicsCategory.Transfer
          })
        }
      }
    }
  }
  
  deinit {
    
  }
  
}


