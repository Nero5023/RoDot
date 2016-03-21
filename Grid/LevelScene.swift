//
//  LevelScene.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/28.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class LevelScene: SKScene {
  
  // MARK: Properties
  var bgNode = SKNode()
  var spritesNode = SKNode()
  var hudNode = SKNode()
  var overlayNode = SKNode()
  
  var entities = Set<GKEntity>()
  
  var lastUpdateTimeInterval: NSTimeInterval = 0
  
  lazy var componentSystems: [GKComponentSystem] = {
  let moveSystem = GKComponentSystem(componentClass: MoveComponent.self)
    
    return [moveSystem]
  }()
  
  var moveableInputComponent: InputComponent?
  
  // In the didSimulatePhysics do the block
  var restRotatingCompletionBlock: (()->())?

  var isResting: Bool = false
  
  var currentLevel: Int = 0
  
  var playable: Bool = false
  
  
  // Class Methods:
  
  class func level(levelNum: Int) -> LevelScene? {
    let scene = LevelScene(fileNamed: "Level\(levelNum)")!
    scene.currentLevel = levelNum
    scene.scaleMode = .AspectFill
    return scene
  }
  

 

  // MARK: Scene Life Cycle
  
  override func didMoveToView(view: SKView) {
    setUpScene()
    setUpNode()
    
    physicsWorld.contactDelegate = self
    
    enumerateChildNodesWithName("//*", usingBlock: { [unowned self] node, _  in
      if let node = node as? RodNode {
       let entity =  Rod(renderNode: node)
        node.removeFromParent()
        self.addEntity(entity)
      }
      if let node = node as? RotationPointNode  {
        
        let nodeType = PointNodeType(nodeName: node.name)

        node.removeFromParent()
        self.addEntity(nodeType.pointEntity(node))
      }
      
      
      if let ballNode = node as? BallNode {
        ballNode.didMoveToScene()
      }
      if let iceball = node as? IceBallNode {
        iceball.didMoveToScene()
      }
      if let destination = node as? DestinationNode {
        destination.didMoveToScene()
      }
      
      if let nodeName = node.name, node = node as? TransferNode {
        if nodeName.hasPrefix("transfer") {
          let entity = Transfer(renderNode: node)
          self.addEntity(entity)
        }
      }
      
    })
    
    for entity in entities {
      if let intelligenceComponent = entity.componentForClass(IntelligenceComponent.self) {
        intelligenceComponent.enterInitialState()
      }else {
        entity.componentForClass(RelateComponent.self)?.updateRelatedNodes()
      }
    }
    initializeAnimation()
    addTopRootRectangle()
  }
  
  func addTopRootRectangle() {
    let upRectangle = SKSpriteNode(texture: nil, color: UIColor(red: 0, green: 0, blue: 0, alpha: 0), size: CGSize(width: self.size.width, height: 10))
    upRectangle.physicsBody = SKPhysicsBody(rectangleOfSize: upRectangle.size)
    upRectangle.physicsBody?.categoryBitMask = PhysicsCategory.Rod
    upRectangle.physicsBody?.collisionBitMask = PhysicsCategory.Ball
    upRectangle.physicsBody!.dynamic = false
    upRectangle.position = CGPoint(x: self.size.width/2, y: self.size.height+2)
    childNodeWithName("Sprites")?.addChild(upRectangle)
  }
  
  func initializeAnimation() {
    for entity in entities {
      if let entity = entity as? BasePointEntity {
        let node = entity.componentForClass(RenderComponent.self)!.node
        node.setScale(0.01)
        let action0 = SKAction.scaleTo(1.15, duration: 1)
        let action1 = SKAction.scaleTo(0.85, duration: 0.5)
        let action2 = SKAction.scaleTo(1, duration: 0.5)
        action0.timingMode = SKActionTimingMode.EaseInEaseOut
        action1.timingMode = SKActionTimingMode.EaseInEaseOut
        action2.timingMode = SKActionTimingMode.EaseInEaseOut
        node.runAction(SKAction.sequence([action0, action1, action2]))
      }
      if let entity = entity as? Rod {
        let node = entity.componentForClass(RenderComponent.self)!.node
        let originalPosition = node.position
        let originalZRotation = node.zRotation
        node.position = CGPoint(x: CGFloat.random(min: 105, max: 1536-105), y: CGFloat.random(min: -200, max: -105))
        node.zRotation = CGFloat.random(min: 0, max: 360).degreesToRadians()
        
        let duration = NSTimeInterval(CGFloat.random(min: 0.8, max: 1.7))
        
        let action0 = SKAction.rotateToAngle(originalZRotation, duration: duration)
        let action1 = SKAction.moveTo(originalPosition, duration: duration)
        action0.timingMode = SKActionTimingMode.EaseInEaseOut
        action1.timingMode = SKActionTimingMode.EaseInEaseOut
        node.runAction(SKAction.group([action0, action1]))
      }
    }
    let ball = spritesNode.childNodeWithName("ball")!
    ball.setScale(0.01)
    ball.physicsBody?.affectedByGravity = false
    ball.physicsBody = nil
    let action = SKAction.sequence([SKAction.waitForDuration(1.4),
      SKAction.scaleTo(1, duration: 0.3),
      SKAction.runBlock({ [unowned self] in
      (ball as? BallNode)?.didMoveToScene()
      self.playable = true
    })])
    ball.runAction(action)
  }
  
  func setUpNode() {
    bgNode = childNodeWithName("Background")!
    bgNode.zPosition = -1
    spritesNode = childNodeWithName("Sprites")!
    spritesNode.zPosition = 50
    hudNode = childNodeWithName("HUD")!
    hudNode.zPosition = 100
    overlayNode = childNodeWithName("Overlay")!
    overlayNode.zPosition = 150
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
  
  
  // MARK: Touch Event
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard touches.count == 1 else { return }
    guard let firstTouchPosition = touches.first?.locationInNode(spritesNode) else { return }
    guard moveableInputComponent == nil else { return }
    guard isResting == false else { return }
    guard playable else { return }
    if let entityNode = spritesNode.nodeAtPoint(firstTouchPosition) as? EntityNode,
        let inputComponent = entityNode.entity.componentForClass(InputComponent.self) {
          moveableInputComponent = inputComponent
        inputComponent.touchesBegan(touches, withEvent: event)
    }
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard touches.count == 1 else { return }
    guard let firstTouchPosition = touches.first?.locationInNode(spritesNode) else { return }
    guard isResting == false else { return }
    guard playable else { return }
    if let moveableInputComponent = moveableInputComponent {
      moveableInputComponent.touchesMoved(touches, withEvent: event)
    }else {
      if let entityNode = spritesNode.nodeAtPoint(firstTouchPosition) as? EntityNode,
        let inputComponent = entityNode.entity.componentForClass(InputComponent.self) {
          moveableInputComponent = inputComponent
          inputComponent.touchesBegan(touches, withEvent: event)
      }
    }
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard isResting == false else { return }
    moveableInputComponent?.touchesEnded(touches, withEvent: event)
    moveableInputComponent = nil
  }
  
  // Mark: Scene Life Cycle
  
  // Update
  override func update(currentTime: NSTimeInterval) {
    super.update(currentTime)
    
    guard view != nil else { return }
    
    let deltaTime = currentTime - lastUpdateTimeInterval
    lastUpdateTimeInterval = currentTime
    
    
    if paused { return }
    
    for componentSystem in componentSystems {
      componentSystem.updateWithDeltaTime(deltaTime)
    }
    
  }
  
  override func didSimulatePhysics() {
    if let restRotatingCompletionBlock = restRotatingCompletionBlock {
      restRotatingCompletionBlock()
      physicsWorld.removeAllJoints()
      self.restRotatingCompletionBlock = nil
      isResting = false
    }
  }
  
  // MARK: Convenience Methods
  
  func addEntity(entity: GKEntity) {
    entities.insert(entity)
    
    for componentSystem in componentSystems {
      componentSystem.addComponentWithEntity(entity)
      
    }
    
    if let renderNode = entity.componentForClass(RenderComponent.self)?.node {
        addNode(renderNode, toLayer: spritesNode)
    }
    
//    if let intelligenceComponent = entity.componentForClass(IntelligenceComponent.self) {
//      intelligenceComponent.enterInitialState()
//    }
  }
  
  
  func addNode(node: SKNode, toLayer layerNode: SKNode) {
    layerNode.addChild(node)
  }
  
  // MARK: Game Life Cycle
  
  func newGame() {
//    var newScene: LevelScene?
//    if let scene = editScene {
//      newScene = scene
//      newScene?.editScene = editScene?.copy() as? LevelScene
//    }else {
//      newScene = LevelScene.level(currentLevel)
//    }
//    newScene!.scaleMode = scaleMode
//    view!.presentScene(newScene)
    let scene = LevelScene.level(currentLevel)
    scene!.scaleMode = scaleMode
    view!.presentScene(scene)
  }
  
  func lose() {
    playable = false
    performSelector("newGame", withObject: nil, afterDelay: 1)
  }
  
  func win() {
    playable = false
    for entity in entities {
      if let entity = entity as? Rod {
        afterDelay(NSTimeInterval(0), runBlock: {
          let node = entity.componentForClass(RenderComponent.self)!.node
          let action = SKAction.scaleTo(0, duration: 0.5)
          action.timingMode = SKActionTimingMode.EaseInEaseOut
          node.runAction(action)
        })
      }
      if let entity = entity as? BasePointEntity {
        entity.componentForClass(RenderComponent.self)!.node.runAction(SKAction.scaleTo(0.01, duration: 0.8))
      }
    }
    if currentLevel < 7 {
      currentLevel++
    }
    performSelector("newGame", withObject: nil, afterDelay: 1)
  }
}

// MARK: Contect

extension LevelScene: SKPhysicsContactDelegate {
  
  func didBeginContact(contact: SKPhysicsContact) {
    let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    if collision == PhysicsCategory.Ball | PhysicsCategory.Transfer {
      let transfer = contact.bodyA.categoryBitMask == PhysicsCategory.Transfer ? contact.bodyA.node : contact.bodyB.node
      let ball = contact.bodyA.categoryBitMask == PhysicsCategory.Ball ? contact.bodyA.node : contact.bodyB.node
      if let transfer = transfer as? EntityNode, ball = ball as? SKSpriteNode {
        transfer.entity.componentForClass(TransferComponent.self)?.transferNode(ball)
      }
    }
    // 可以用 collision & PhysicsCategory.Transfer 看看是不是 Transfer 
    if collision == PhysicsCategory.IceBall | PhysicsCategory.Transfer {
      let transfer = contact.bodyA.categoryBitMask == PhysicsCategory.Transfer ? contact.bodyA.node : contact.bodyB.node
      if let transfer = transfer as? EntityNode {
        (transfer.entity as! FreezableProtocol).setNodeIsFreezed(true)
      }
    }
    
    
    
    if !playable { return }
    
    if collision == PhysicsCategory.Ball | PhysicsCategory.Distance {
      print("win")
      let ball = contact.bodyA.categoryBitMask == PhysicsCategory.Ball ? contact.bodyA.node : contact.bodyB.node
      let distance = contact.bodyA.categoryBitMask == PhysicsCategory.Distance ? contact.bodyA.node : contact.bodyB.node
      ball!.physicsBody = nil
      ball!.runAction(SKAction.group([SKAction.moveTo(distance!.position, duration: 0.8), SKAction.scaleTo(0.01, duration: 0.8)]))
      
      playable = false
      touchesEnded([], withEvent: nil)
      afterDelay(0.5, runBlock: {
        self.win()
      })
    }
    
    if collision == PhysicsCategory.Ball | PhysicsCategory.Edge {
      print("Lose")
      lose()
    }
    
  }
  
  func didEndContact(contact: SKPhysicsContact) {
    let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    if collision == PhysicsCategory.Ball | PhysicsCategory.Transfer {
      let transfer = contact.bodyA.categoryBitMask == PhysicsCategory.Transfer ? contact.bodyA.node : contact.bodyB.node
      if let transfer = transfer as? EntityNode {
        transfer.entity.componentForClass(TransferComponent.self)?.endTransfer()
      }
    }
  }
}


