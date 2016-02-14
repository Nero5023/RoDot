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
  var isFinishRotation = false
  var rotatingRodNode: RodNode?
  
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
//    setUp()
   
  }
  
  func finshRotation(notification: NSNotification) {
    if let rodNode = notification.object as? RodNode {
      isFinishRotation = true
      rodNode.updateRelatedPointNodeState()
      rotatingRodNode = rodNode
    }
  }
  

  
  override func update(currentTime: CFTimeInterval) {
    
  }
  

  
  override func didSimulatePhysics() {
    if isFinishRotation {
      if let rotatingPointNode = rotatingRodNode?.rotatingNode {
        gridGraph.setAllRelatedRodsDynamicWithRotationNode(rotatingPointNode)
        rotatingRodNode?.rotatingNode = nil
      }
      physicsWorld.removeAllJoints()
      isFinishRotation = false
    }
  }
  
  
  
  
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: kDidFinshRotationgNotification, object: nil)
  }
  
}


