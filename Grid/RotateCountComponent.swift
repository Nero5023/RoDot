//
//  RotateCountComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/14.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class RotateCountComponent: GKComponent {
  
  // MARK: Properties
  
  private var rotateCount: Int
  
  private var rotateCountNodes = [SKSpriteNode]()
  
  var intelligenceComponent: IntelligenceComponent {
    guard let intelligenceComponent = entity?.componentForClass(IntelligenceComponent.self) else {
      fatalError("The RotateCountComponent's entity must have a IntelligenceComponent")
    }
    return intelligenceComponent
  }
  
  var renderComponent: RenderComponent {
    guard let renderComponent = entity?.componentForClass(RenderComponent.self) else {
      fatalError("The RotateCountComponent's entity must have a RenderComponent")
    }
    return renderComponent
  }
  
  // MARK: Initializers
  
  init(rotateCount: Int) {
    self.rotateCount = rotateCount
  }
  
  func addRotateCountNode() {
    var zRotation: CGFloat = 90
    if rotateCount == 2 {
      zRotation = 180
    }
    for i in 0..<rotateCount {
      let node = SKSpriteNode(imageNamed: "rotatecount")
      node.zRotation = CGFloat(i) * zRotation.degreesToRadians()
      rotateCountNodes.append(node)
      renderComponent.node.addChild(node)
    }
  }
  
  func endRotating() {
    rotateCount -= 1
    var removeNode: SKSpriteNode
    var removeIndex: Int
    if self.rotateCountNodes.count == 3 {
      removeNode = self.rotateCountNodes[1]
      removeIndex = 1
    }else {
      removeNode = self.rotateCountNodes.last!
      removeIndex = self.rotateCountNodes.count - 1
    }
    removeNode.runAction(SKAction.sequence([
      SKAction.scaleTo(0, duration: 0.5),
      SKAction.runBlock({
        removeNode.removeFromParent()
        self.rotateCountNodes.removeAtIndex(removeIndex)
      })
      ]))
    
    if rotateCount == 0 {
      
      for node in renderComponent.node.children where node.name == "bubble" {
        node.runAction(SKAction.sequence([
          SKAction.scaleTo(0, duration: 0.33),
          SKAction.runBlock({node.removeFromParent()})
          ]))
      }
      renderComponent.node.runAction(SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 1, duration: 0.33))
      
      
      intelligenceComponent.stateMachine.enterState(PointLockedForeverState.self)
    }
  }
  
}
