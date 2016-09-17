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
  
  fileprivate var rotateCount: Int
  
  fileprivate var rotateCountNodes = [SKSpriteNode]()
  
  var intelligenceComponent: IntelligenceComponent {
    guard let intelligenceComponent = entity?.component(ofType: IntelligenceComponent.self) else {
      fatalError("The RotateCountComponent's entity must have a IntelligenceComponent")
    }
    return intelligenceComponent
  }
  
  var renderComponent: RenderComponent {
    guard let renderComponent = entity?.component(ofType: RenderComponent.self) else {
      fatalError("The RotateCountComponent's entity must have a RenderComponent")
    }
    return renderComponent
  }
  
  // MARK: Initializers
  
  init(rotateCount: Int) {
    self.rotateCount = rotateCount
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func addRotateCountNode() {
//    var zRotation: CGFloat = 90
//    if rotateCount == 2 {
//      zRotation = 180
//    }
//    for i in 0..<rotateCount {
//      let node = SKSpriteNode(imageNamed: "rotatecount")
//      node.name = "rotatecount"
//      node.zRotation = CGFloat(i) * zRotation.degreesToRadians()
//      rotateCountNodes.append(node)
//      renderComponent.node.addChild(node)
//    }
    rotateCountNodes = SceneManager.sharedInstance.addRotateCountNodes(renderComponent.node, rotateCount: rotateCount)
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
    removeNode.run(SKAction.sequence([
      SKAction.scale(to: 0, duration: 0.5),
      SKAction.run({
        removeNode.removeFromParent()
        self.rotateCountNodes.remove(at: removeIndex)
      })
      ]))
    
    if rotateCount == 0 {
      
      for node in renderComponent.node.children where node.name == "bubble" {
        node.run(SKAction.sequence([
          SKAction.scale(to: 0, duration: 0.33),
          SKAction.run({node.removeFromParent()})
          ]))
      }
      renderComponent.node.run(SKAction.colorize(with: UIColor.black, colorBlendFactor: 1, duration: 0.33))
      
      
      intelligenceComponent.stateMachine.enter(PointLockedForeverState.self)
    }
  }
  
}
