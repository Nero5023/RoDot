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
  
  var playable: Bool = true
  
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
        
//        var entity: BasePointEntity
        let nodeType = PointNodeType(nodeName: node.name)
//        switch nodeType {
//        case .normalNode:
//          entity = RotationPoint(renderNode: node)
//        case .restrictedNode1, .restrictedNode2, .restrictedNode3, .restrictedNode4:
//          entity = RestrictedRotationPoint(renderNode: node, rotatableRodCount: nodeType.tag)
//        case .staticNode:
//          entity = StaticPoint(renderNode: node)
//        case .translationNode:
//          entity = TranslationPoint(renderNode: node)
//        case .cNormalNode:
//          entity = ClockwiseRotationPoint(renderNode: node, isClockwise: true)
//        case .acNormalNode:
//          entity = ClockwiseRotationPoint(renderNode: node, isClockwise: false)
//        case .cRestrictedNode1, .cRestrictedNode2, .cRestrictedNode3, .cRestrictedNode4:
//          entity = ClockwiseRescritedRPoint(renderNode: node, rotatableRodCount: nodeType.tag, isClockwise: true)
//        case .acRestrictedNode1, .acRestrictedNode2, .acRestrictedNode3, .acRestrictedNode4:
//          entity = ClockwiseRescritedRPoint(renderNode: node, rotatableRodCount: nodeType.tag, isClockwise: false)
//        }
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
    guard let firstTouchPosition = touches.first?.locationInNode(spritesNode) else { return }
    guard isResting == false else { return }
    if let entityNode = spritesNode.nodeAtPoint(firstTouchPosition) as? EntityNode,
        let inputComponent = entityNode.entity.componentForClass(InputComponent.self) {
          moveableInputComponent = inputComponent
        inputComponent.touchesBegan(touches, withEvent: event)
    }
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard isResting == false else { return }
    moveableInputComponent?.touchesMoved(touches, withEvent: event)
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
    let scene = LevelScene.level(currentLevel)
    scene!.scaleMode = scaleMode
    view!.presentScene(scene)
  }
  
  func lose() {
    playable = false
    performSelector("newGame", withObject: nil, afterDelay: 2)
  }
  
  func win() {
    playable = false
    if currentLevel < 6 {
      currentLevel++
    }
    performSelector("newGame", withObject: nil, afterDelay: 2)
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
      win()
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
