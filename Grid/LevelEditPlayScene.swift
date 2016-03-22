//
//  LevelEditPlayScene.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/21.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class LevelEditPlayScene: LevelScene {
  
  // MARK: Properties
  var editPlayScene: LevelEditPlayScene?
  var editScene: LevelEditorScene?
  
  
  // MARK: Class Methods
  class func editScene(rods: [SKSpriteNode], points: [PointButton], ball: SKSpriteNode, destination: SKSpriteNode) -> LevelEditPlayScene? {
    let scene = LevelEditPlayScene(fileNamed: "LevelEmpty")
    
    guard let sprites = scene?.childNodeWithName("Sprites") else {
      fatalError("The LevelEditPlayScene must have a node named Sprites")
    }

    var minPoint = CGPoint(x: 10000, y: 10000)
    var maxPoint = CGPoint(x: 0, y: 0)
    for rod in rods {
      if rod.name == "rod" {
        
        let rodNode = copyNode(rod, toType: RodNode.self)
        sprites.addChild(rodNode)
        
        calculate(&minPoint, maxPoint: &maxPoint, withNode: rodNode)
      }
    }
    for point in points {
      if point.type != nil {
        
        let pointNode = copyNode(point, toType: RotationPointNode.self)
        sprites.addChild(pointNode)
        
        calculate(&minPoint, maxPoint: &maxPoint, withNode: pointNode)
      }
    }
    
    
    
    let ballNode = copyNode(ball, toType: BallNode.self)
    sprites.addChild(ballNode)
    
    let destinationNode = copyNode(destination, toType: DestinationNode.self)
    sprites.addChild(destinationNode)
    
    calculate(&minPoint, maxPoint: &maxPoint, withNode: ballNode)
    calculate(&minPoint, maxPoint: &maxPoint, withNode: destinationNode)

    let centerPosition = (minPoint + maxPoint)/2
    
    let vector = CGPoint(x: scene!.size.width/2, y: scene!.size.height/2) - centerPosition
    for node in sprites.children {
      node.position += vector
    }
    
    scene?.editPlayScene = scene?.copy() as? LevelEditPlayScene
    return scene
  }
  
  // MARK: Scene Life Cycle
  
  override func didMoveToView(view: SKView) {
    super.didMoveToView(view)
    let editNode = scene?.childNodeWithName("Overlay")?.childNodeWithName("editButton") as? SKSpriteNode
    let editButton = copyNode(editNode!, toButtonType: SKButtonNode.self, selectedTextue: nil, disabledTextue: nil)
    editNode!.removeFromParent()
    editButton.actionTouchUpInside = {
      self.view!.presentScene(self.editScene)
    }
    childNodeWithName("Overlay")?.addChild(editButton)
  }
  
  override func newGame() {
    guard let editPlayScene = editPlayScene else {
      fatalError("The LevelEditPlayScene must have a editScene")
    }
    let newScene = editPlayScene
    newScene.editPlayScene = newScene.copy() as? LevelEditPlayScene
    newScene.editScene = self.editScene
    newScene.scaleMode = self.scaleMode
    view?.presentScene(newScene)
    print(view)
  }
  
  
}


// MARK: Help Functions

private func copyNode(node:SKSpriteNode, toType Type: SKSpriteNode.Type) -> SKSpriteNode {
  let copyNode = Type.init(texture: node.texture)
  copyNode.size = node.size
  copyNode.position = node.position
  copyNode.name = node.name
  copyNode.zRotation = node.zRotation
  return copyNode
}

private func calculate(inout minPoint: CGPoint, inout maxPoint: CGPoint, withNode node: SKSpriteNode) {
  minPoint.x = min(minPoint.x, node.position.x)
  minPoint.y = min(minPoint.y, node.position.y)
  maxPoint.x = max(maxPoint.x, node.position.x)
  maxPoint.y = max(maxPoint.y, node.position.y)
}