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
    guard let renderComponent = entity?.component(ofType: RenderComponent.self) else {
      fatalError("A TransferComponent's entity must have a RenderComponent ")
    }
    return renderComponent
  }
  
  var targetNodeName: String
  
  var relatedNode: EntityNode {
    guard let entityNode = renderComponent.node.parent?.childNode(withName: targetNodeName) as? EntityNode else {
      fatalError("A TransferComponent's entity's renderComponent's parent must have a node named \(targetNodeName) ")
    }
    return entityNode
  }
  
  var allowTransfer: Bool = true {
    didSet {
      relatedNode.entity.component(ofType: TransferComponent.self)!.allowTransfer = allowTransfer
    }
  }
  
  var isContacting: Bool = false
  
  // MARK: Initializers
  init(renderNodeName: String) {
    guard let targetNodeName = GameplayConfiguration.transferTargetNames[renderNodeName] else {
      fatalError("In the GameplayConfiguration.transferTargetNames(dic) must have a key named \(renderNodeName)")
    }
    self.targetNodeName = targetNodeName
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Action
  
  func transferNode(_ node: SKSpriteNode) {
    isContacting = true
    if entity?.component(ofType: FreezableComponent.self)?.isFreezd == true { return }
    if allowTransfer {
      isContacting = false
      relatedNode.entity.component(ofType: TransferComponent.self)?.getTransferNode(node)
    }
  }
  
  func getTransferNode(_ node: SKSpriteNode) {
    node.removeFromParent()
    node.position = renderComponent.node.position
    renderComponent.node.parent?.addChild(node)
    allowTransfer = false
    isContacting = true
  }
  
  func endTransfer() {
    isContacting = false
    if entity?.component(ofType: FreezableComponent.self)?.isFreezd == true { return }
    if !isContacting && !relatedNode.entity.component(ofType: TransferComponent.self)!.isContacting {
      allowTransfer = true
    }
  }
  

}
