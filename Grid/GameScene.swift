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
  
  override func didMove(to view: SKView) {
    setUpScene()
    setUpNode()
    
    physicsWorld.contactDelegate = self
    
    enumerateChildNodes(withName: "//*", using: {node, _ in
      if let customNode = node as? CustomNodeEvents {
        customNode.didMoveToScene()
      }
    })
    
  }
  
  //Set up nodes
  func setUpNode() {
    bgNode = childNode(withName: "Background")!
    spritesNode = childNode(withName: "Sprites")!
    hudNode = childNode(withName: "HUD")!
    overlayNode = childNode(withName: "Overlay")!
  }
  
  func setUpScene() {
    let maxAspectRatio: CGFloat = 16.0/9.0
    let maxAspectRatioWidth = size.height / maxAspectRatio
    
    let playableMargin: CGFloat = (size.width - maxAspectRatioWidth)/2
    let playableRect = CGRect(x: playableMargin, y: 0, width: size.width - playableMargin*2, height: size.height)
    physicsBody = SKPhysicsBody(edgeLoopFrom: playableRect)
    physicsBody!.categoryBitMask = PhysicsCategory.Edge
    physicsBody!.collisionBitMask = PhysicsCategory.Ball
  }
  

  // MARK: Update
  override func update(_ currentTime: TimeInterval) {
    if let compound = compound, let lastTouchedPosition = lastTouchedPosition {
      let angle = angleWith(compound.convert(rotatingRodNode!.position, to: spritesNode) - compound.convert(rotatingRodNode!.rotatingNode!.position, to: spritesNode),
        vector: lastTouchedPosition - compound.convert(rotatingRodNode!.rotatingNode!.position, to: spritesNode))
      
      
      compound.physicsBody?.angularVelocity = angle * 10
    }
  }
  
  // The shorest angle between two vector
  func angleWith(_ lastVector: CGPoint, vector: CGPoint) -> CGFloat {
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
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isResting == false else { return }
    let touchLocation = touches.first!.location(in: spritesNode)
    if let rodNode = atPoint(touchLocation) as? RodNode {
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
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isResting == false else { return }
    // Check the if already reference to the rotatingRodNode
    guard let rotatingRodNode = rotatingRodNode else { return }
    
    // Check if compound the nodes
    if let _ = compound {
      lastTouchedPosition = touches.first?.location(in: spritesNode)
    }else {
      rotatingRodNode.checkRotation(touches, withEvent: event)
      if rotatingRodNode.isRotating {
        addCompound()
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isResting == false else { return }
    // May can put it in the restRotation
//    isResting = true
    restRotation()
  }
  
  // Make compounds
  func addCompound() {
    guard let rotatingRodNode = rotatingRodNode, let rotationPointNode = rotatingRodNode.rotatingNode
      else { return }
    let centerPosition = rotationPointNode.position
    if let compound = gridGraph.makeCompoundNode(withPointNode: rotationPointNode) {
      spritesNode.addChild(compound)
      let pinJoint = SKPhysicsJointPin.joint(withBodyA: compound.physicsBody!, bodyB: physicsBody!, anchor: centerPosition)
      pinJoint.frictionTorque = 1
      pinJoint.rotationSpeed = 0.01
      physicsWorld.add(pinJoint)
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
        node.position = compound.convert(node.position, to: spritesNode)
        //Don't know why it doesn't work
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 22, height: node.size.height-8), center: node.position)
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.isDynamic = false
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
        let fixJoint = SKPhysicsJointFixed.joint(withBodyA: rod.physicsBody!, bodyB: rotatingRodNode!.rotatingNode!.physicsBody!,
          anchor: self.convert(rotatingRodNode!.rotatingNode!.position, from: rod.parent!))
        rod.physicsBody!.isDynamic = true
        physicsWorld.add(fixJoint)
      }
//      let fixJoint = SKPhysicsJointFixed.jointWithBodyA(rod.physicsBody!, bodyB: node.physicsBody!, anchor: scene.convertPoint(node.position, fromNode: node.parent!))
//      rod.physicsBody!.dynamic = true
//      scene.physicsWorld.addJoint(fixJoint)
    }
    
  }
  
  func restRotation() {
    guard let rotatingRodNode = rotatingRodNode,  let _ = compound else { return }
    if let rotatingPointNode = rotatingRodNode.rotatingNode {
      decompound()
//      gridGraph.attachJointFixToPointNode(rotatingPointNode, atScene: self)
      //Rest the nodes position
      let angle = rotatingPointNode.zRotation.truncatingRemainder(dividingBy: (π/2.0))
      isResting = true
      if abs(angle) <  π/4.0 {
        let action = SKAction.sequence([SKAction.rotate(byAngle: -angle, duration: 0.4),
          SKAction.run({ [unowned self] in
            self.finshRotation()
            })
          ])
        rotatingPointNode.run(SKAction.afterDelay(0.1, performAction: action))
      }else {
        let action = SKAction.sequence([SKAction.rotate(byAngle: (π/2-abs(angle))*angle.sign(), duration: 0.4),
          SKAction.run({ [unowned self] in
            self.finshRotation()
            })
          ])
        rotatingPointNode.run(SKAction.afterDelay(0.1, performAction: action))
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
  
  func didBegin(_ contact: SKPhysicsContact) {
    let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    
    if collision == PhysicsCategory.Ball | PhysicsCategory.Transfer {
      let transfer = contact.bodyA.categoryBitMask == PhysicsCategory.Transfer ? contact.bodyA.node : contact.bodyB.node
      let ball = contact.bodyA.categoryBitMask == PhysicsCategory.Ball ? contact.bodyA.node : contact.bodyB.node
      ball!.removeFromParent()
      enumerateChildNodes(withName: "//\(transfer!.name!)") { [unowned self] transferNode, _ in
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


