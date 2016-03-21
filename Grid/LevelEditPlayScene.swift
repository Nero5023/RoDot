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
  
  var editScene: LevelEditPlayScene?
  
  class func editScene(rods: [SKSpriteNode], points: [PointButton], ball: SKSpriteNode, destination: SKSpriteNode) -> LevelScene? {
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
    
    scene?.editScene = scene?.copy() as? LevelEditPlayScene
    
    return scene
  }
  
  override func newGame() {
    guard let editScene = editScene else {
      fatalError("The LevelEditPlayScene must have a editScene")
    }
    let newScene = editScene
    newScene.editScene = newScene.copy() as? LevelEditPlayScene
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