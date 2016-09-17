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
  
  // MARK: Initializers
  
  init(states: [GKState]) {
    stateMachine = GKStateMachine(states: states)
    initialStateClass = type(of: states.first!) as AnyClass
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: GKComponent Life Cycle
  
  override func update(deltaTime seconds: TimeInterval) {
    super.update(deltaTime: seconds)
    
    stateMachine.update(deltaTime: seconds)
  }
  
  func enterInitialState() {
    stateMachine.enter(initialStateClass)
  }
}
