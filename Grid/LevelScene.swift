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
  
  // MARK: Scene Life Cycle
  
  override func didMoveToView(view: SKView) {
    setUpScene()
    setUpNode()
    
    enumerateChildNodesWithName("//*", usingBlock: { [unowned self] node, _  in
      if let node = node as? RodNode {
       let entity =  Rod(renderNode: node)
        node.removeFromParent()
        self.addEntity(entity)
      }
      if let node = node as? RotationPointNode  {
        let entity = RotationPoint(renderNode: node)
        node.removeFromParent()
        self.addEntity(entity)
      }
      if let ballNode = node as? BallNode {
        ballNode.didMoveToScene()
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
  
  // Mark: Update
  
  override func update(currentTime: NSTimeInterval) {
    super.update(currentTime)
    
    guard view != nil else { return }
    
    let deltaTime = currentTime - lastUpdateTimeInterval
    lastUpdateTimeInterval = currentTime
    
    
    if paused { return }
    
    for componentSystem in componentSystems {
      componentSystem.updateWithDeltaTime(deltaTime)
    }
    
    physicsWorld
    
    
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
  
  override func didSimulatePhysics() {
    if let restRotatingCompletionBlock = restRotatingCompletionBlock {
      restRotatingCompletionBlock()
      self.restRotatingCompletionBlock = nil
      isResting = false
    }
  }
  
}
