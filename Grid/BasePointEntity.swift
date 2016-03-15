//
//  BasePointEntity.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/1.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit


//enum PointNodeType: Int {
//  case staticNode = 0, restrictedNode1, restrictedNode2, restrictedNode3, restrictedNode4, cRestrictedNode1, cRestrictedNode2, cRestrictedNode3, cRestrictedNode4, acRestrictedNode1, acRestrictedNode2, acRestrictedNode3, acRestrictedNode4, normalNode, cNormalNode, acNormalNode,translationNode
//  
//  // MARK: Initializers
//  
//  init(nodeName: String?) {
//    guard let nodeName = nodeName else {
//      fatalError("The point node doesn't have a name")
//    }
//    
//    switch nodeName {
//      case "static":
//        self = .staticNode
//      case "1":
//        self = .restrictedNode1
//      case "2":
//        self = .restrictedNode2
//      case "3":
//        self = .restrictedNode3
//      case "4":
//        self = .restrictedNode4
//      case "1cw":
//        self = .cRestrictedNode1
//      case "2cw":
//        self = .cRestrictedNode2
//      case "3cw":
//        self = .cRestrictedNode3
//      case "4cw":
//        self = .cRestrictedNode4
//      case "1ac":
//        self = .acRestrictedNode1
//      case "2ac":
//        self = .acRestrictedNode2
//      case "3ac":
//        self = .acRestrictedNode3
//      case "4ac":
//        self = .acRestrictedNode4
//      case "normal":
//        self = .normalNode
//      case "normalcw":
//        self = .cNormalNode
//      case "normalac":
//        self = .acNormalNode
//      case "translation":
//        self = .translationNode
//      default:
//        fatalError("Unknown pointNodeName: \(nodeName)")
//    }
//  }
//  
//  var tag: Int {
//    switch self {
//    case .restrictedNode1, .restrictedNode2, .restrictedNode3, .restrictedNode4:
//      return self.rawValue
//    case .cRestrictedNode1, .cRestrictedNode2, .cRestrictedNode3, .cRestrictedNode4:
//      return self.rawValue - 4
//    case .acRestrictedNode1, .acRestrictedNode2, .acRestrictedNode3, .acRestrictedNode4:
//      return self.rawValue - 8
//    default:
//      return 0
//    }
//  }
//}

/**
    This is the Bas entity for the Point Entity
*/

class BasePointEntity: GKEntity {
  
  // MARK: Initializers
  
  init(renderNode: SKSpriteNode) {
    super.init()
    
    let renderComponent = RenderComponent(entity: self, renderNode: renderNode)
    addComponent(renderComponent)
    
    let physicsBody = SKPhysicsBody(circleOfRadius: renderComponent.node.size.width/2.0)
    physicsBody.affectedByGravity = false
    physicsBody.dynamic = false
    let physicsComponent = PhysicsComponent(physicsBody:physicsBody, colliderType: GameplayConfiguration.RotationPoint.collider)
    addComponent(physicsComponent)
    
    renderComponent.node.physicsBody = physicsComponent.physicsBody
    renderComponent.node.zPosition = GameplayConfiguration.RotationPoint.zPositon
    
  }
  
}
