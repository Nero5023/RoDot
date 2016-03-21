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
    for rod in rods {
      if rod.name == "rod" {
        
        let rodNode = copyNode(rod, toType: RodNode.self)
        scene?.addChild(rodNode)
      }
    }
    for point in points {
      if point.type != nil {
        
        let pointNode = copyNode(point, toType: RotationPointNode.self)
        scene?.addChild(pointNode)
      }
    }
    
    let ballNode = copyNode(ball, toType: BallNode.self)
    scene?.childNodeWithName("Sprites")?.addChild(ballNode)
    
    let destinationNode = copyNode(destination, toType: DestinationNode.self)
    scene?.childNodeWithName("Sprites")?.addChild(destinationNode)
    
    scene?.editPlayScene = scene?.copy() as? LevelEditPlayScene
    
    let editNode = scene?.childNodeWithName("Overlay")?.childNodeWithName("editButton") as? SKSpriteNode
    let editButton = copyNode(editNode!, toButtonType: SKButtonNode.self, selectedTextue: nil, disabledTextue: nil)
    editNode!.removeFromParent()
    editButton.actionTouchUpInside = {
      scene?.view!.presentScene(scene?.editScene)
    }
    scene?.childNodeWithName("Overlay")?.addChild(editButton)
    
    return scene
  }
  
  override func newGame() {
    guard let editScene = editPlayScene else {
      fatalError("The LevelEditPlayScene must have a editScene")
    }
    let newScene = editScene
    newScene.editPlayScene = newScene.copy() as? LevelEditPlayScene
    newScene.scaleMode = self.scaleMode
    view!.presentScene(newScene)
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