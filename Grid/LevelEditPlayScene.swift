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
  
  var editPlayScene: LevelEditPlayScene?
  var editScene: LevelEditorScene?
  
  class func editScene(rods: [SKSpriteNode], points: [PointButton], ball: SKSpriteNode, destination: SKSpriteNode) -> LevelEditPlayScene? {
    let scene = LevelEditPlayScene(fileNamed: "LevelEmpty")
    var maxX: CGFloat = 0
    var minX: CGFloat = 10000
    var maxY: CGFloat = 0
    var minY: CGFloat = 10000
    for rod in rods {
      if rod.name == "rod" {
        
        let rodNode = copyNode(rod, toType: RodNode.self)
        scene?.childNodeWithName("Sprites")?.addChild(rodNode)
        
        maxX = max(maxX, rodNode.position.x)
        minX = min(minX, rodNode.position.x)
        
        maxY = max(maxY, rodNode.position.y)
        minY = min(minY, rodNode.position.y)
      }
    }
    for point in points {
      if point.type != nil {
        
        let pointNode = copyNode(point, toType: RotationPointNode.self)
        scene?.childNodeWithName("Sprites")?.addChild(pointNode)
        
        maxX = max(maxX, pointNode.position.x)
        minX = min(minX, pointNode.position.x)
        
        maxY = max(maxY, pointNode.position.y)
        minY = min(minY, pointNode.position.y)
      }
    }
    
    
    
    let ballNode = copyNode(ball, toType: BallNode.self)
    scene?.childNodeWithName("Sprites")?.addChild(ballNode)
    
    let destinationNode = copyNode(destination, toType: DestinationNode.self)
    scene?.childNodeWithName("Sprites")?.addChild(destinationNode)
    
    maxX = max(maxX, ballNode.position.x)
    minX = min(minX, ballNode.position.x)
    
    maxY = max(maxY, ballNode.position.y)
    minY = min(minY, ballNode.position.y)
    
    maxX = max(maxX, destinationNode.position.x)
    minX = min(minX, destinationNode.position.x)
    
    maxY = max(maxY, destinationNode.position.y)
    minY = min(minY, destinationNode.position.y)

    
    let centerPosition = CGPoint(x: (minX + maxX)/2, y: (minY + maxY)/2)
    
    let vector = CGPoint(x: scene!.size.width/2, y: scene!.size.height/2) - centerPosition
    for node in scene!.childNodeWithName("Sprites")!.children {
      node.position += vector
    }
    
    scene?.editPlayScene = scene?.copy() as? LevelEditPlayScene
    return scene
  }
  
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
  
  // TODO: Bug: when win or lose, touch the edit button, the bug happened
  override func newGame() {
    guard let editPlayScene = editPlayScene else {
      fatalError("The LevelEditPlayScene must have a editScene")
    }
    let newScene = editPlayScene
    newScene.editPlayScene = newScene.copy() as? LevelEditPlayScene
    newScene.editScene = self.editScene
    newScene.scaleMode = self.scaleMode
    view?.presentScene(newScene)
  }
  
  
}


private func copyNode(node:SKSpriteNode, toType Type: SKSpriteNode.Type) -> SKSpriteNode {
  let copyNode = Type.init(texture: node.texture)
  copyNode.size = node.size
  copyNode.position = node.position
  copyNode.name = node.name
  copyNode.zRotation = node.zRotation
  return copyNode
}