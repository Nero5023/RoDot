//
//  ClockwiseComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/9.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class ClockwiseComponent: GKComponent {
  
  // MARK: Properties
  
  var isClockwise: Bool
  
  
  var renderComponent: RenderComponent {
    guard let renderComponent = entity?.componentForClass(RenderComponent.self) else {
      fatalError("The ClockwiseComponent's entity must have a RenderComponent")
    }
    return renderComponent
  }
  
  // MARK: Initializers
  
  init(isClockwise: Bool) {
    self.isClockwise = isClockwise
    super.init()
  }
  
  func calculateAngularVelocity(angularVelocity: CGFloat) -> CGFloat {
    var aVelocity = angularVelocity
    if isClockwise {
      if angularVelocity > 0 || angularVelocity < -π/6*4{
        aVelocity = 0
      }
    }else {
      if angularVelocity < 0 || angularVelocity > π/6*4 {
        aVelocity = 0
      }
    }
    return aVelocity
  }
  
  func animationBubble() {
    let animationDuration: NSTimeInterval = 1
    
    let bubbles = renderComponent.node.children.filter{ $0.name == "bubble" }
    for (index, bubble) in bubbles.enumerate() {
//      let path = UIBezierPath(ovalInRect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 32, height: 32)))
      let path = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: 16, startAngle: CGFloat(0).degreesToRadians(), endAngle: CGFloat(360).degreesToRadians(), clockwise: false)
//      path.applyTransform(CGAffineTransformMakeRotation(90))
     
      // this is the colckwise animation
      let rotateAction = SKAction.followPath(path.CGPath, asOffset: false, orientToPath: false, duration: animationDuration)
      var foreverRotation = SKAction.repeatActionForever(rotateAction)
      if !isClockwise {
        foreverRotation = SKAction.repeatActionForever(rotateAction.reversedAction())
      }

      let waitDuration = animationDuration/NSTimeInterval(bubbles.count)*NSTimeInterval(index)
      let waitAction = SKAction.waitForDuration(waitDuration)
      bubble.runAction(SKAction.sequence([waitAction, foreverRotation]))
    }
  }
  
}
