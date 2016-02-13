//
//  GridLineNode.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/9.
//  Copyright © 2016年 Nero. All rights reserved.
//


// 没有用！！！！！！！


import SpriteKit

class GridLineNode: SKSpriteNode, CustomNodeEvents {
  
  static func makeCompoundNode(inScene scene: SKScene) -> SKNode {
    let compound = GridLineNode()
    compound.zPosition = -1
    
    for line in scene.children.filter({ node in node is GridLineNode}) {
      line.removeFromParent()
      compound.addChild(line)
    }
    print(compound.children.first?.frame.size)
    
    
    let bodies = compound.children.map({ node in

      SKPhysicsBody(rectangleOfSize: node.frame.size, center: node.position)
    })
    
    compound.physicsBody = SKPhysicsBody(bodies: bodies)
    compound.physicsBody?.affectedByGravity = false
    
    print(compound.position, compound.size)
    
    return compound
    
  }
  
  
  func didMoveToScene() {
    let levelScene = scene
    if parent == levelScene {
      let compound = GridLineNode.makeCompoundNode(inScene: levelScene!)
      levelScene!.addChild(compound)
    }
  }
  
}
