//
//  IntelligenceComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/27.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class IntelligenceComponent: GKComponent {
  
  // MARK: Properties
  
  let stateMachine: GKStateMachine
  let initialStateClass: AnyClass
  
  init(states: [GKState]) {
    stateMachine = GKStateMachine(states: states)
    initialStateClass = states.first!.dynamicType
  }
  
  override func updateWithDeltaTime(seconds: NSTimeInterval) {
    super.updateWithDeltaTime(seconds)
    
    stateMachine.updateWithDeltaTime(seconds)
  }
  
  func enterInitialState() {
    stateMachine.enterState(initialStateClass)
  }
}
