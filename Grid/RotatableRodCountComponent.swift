//
//  RotatableRodCountComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/2.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class RotatableRodCountComponent: GKComponent {
  
  // MARK: Properties
  
  var rotatableRodCount: Int
  
  var renderComponent: RenderComponent {
    guard let renderComponent = entity?.componentForClass(RenderComponent.self) else {
      fatalError("The RotateCountComponent's entity must have a RenderComponent")
    }
    return renderComponent
  }
  
  // MARK: Initializers
  
  init(rotatableRodCount: Int) {
    self.rotatableRodCount = rotatableRodCount
  }
  
  func addBubbles() {
    var zRotateion:CGFloat = 90
    if rotatableRodCount == 3 {
      zRotateion = 120
    }
    
    for i in 0..<rotatableRodCount {
      let bubble = SKSpriteNode(texture: SKTexture(imageNamed: "bubble"))
      let angle = (CGFloat(i) * zRotateion).degreesToRadians()
      bubble.position = CGPoint(x: sin(angle)*18, y: cos(angle)*18)
      bubble.name = "bubble"
      renderComponent.node.addChild(bubble)
    }
    
  }
}
