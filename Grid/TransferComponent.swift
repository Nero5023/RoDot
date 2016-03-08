//
//  TransferComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/8.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class TransferComponent: GKComponent {
  
  // MARK: Properties
  var renderComponent: RenderComponent {
    guard let renderComponent = entity?.componentForClass(RenderComponent.self) else {
      fatalError("A TransferComponent's entity must have a RenderComponent ")
    }
    return renderComponent
  }
  
  var targetNodeName: String
  
  var relatedNode: EntityNode {
    guard let entityNode = renderComponent.node.parent?.childNodeWithName(targetNodeName) as? EntityNode else {
      fatalError("A TransferComponent's entity's renderComponent's parent must have a node named \(targetNodeName) ")
    }
    return entityNode
  }
  
  var allowTransfer: Bool = true {
    didSet {
      relatedNode.entity.componentForClass(TransferComponent.self)!.allowTransfer = allowTransfer
    }
  }
  
  // MARK: Initializers
  init(renderNodeName: String) {
    guard let targetNodeName = GameplayConfiguration.transferTargetNames[renderNodeName] else {
      fatalError("In the GameplayConfiguration.transferTargetNames(dic) must have a key named \(renderNodeName)")
    }
    self.targetNodeName = targetNodeName
    super.init()
  }
  
  // MARK: Action
  
  func transferNode(node: SKSpriteNode) {
    if allowTransfer {
      relatedNode.entity.componentForClass(TransferComponent.self)?.getTransferNode(node)
    }
  }
  
  func getTransferNode(node: SKSpriteNode) {
    node.removeFromParent()
    node.position = renderComponent.node.position
    renderComponent.node.parent?.addChild(node)
    allowTransfer = false
  }
  
  func endTransfer() {
    allowTransfer = true
  }
  

}
