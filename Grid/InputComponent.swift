//
//  InputComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/27.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class InputComponent: GKComponent {
  
  struct InputState {
    var touchPosition: CGPoint?
    var centerPosition: CGPoint?
    var moveNode: SKSpriteNode?
    
    var isRotating = false
    static let initialSate = InputState()
  }
  
  // MARK: Properties
  
  var renderComponent: RenderComponent {
    guard let renderComponent = entity?.componentForClass(RenderComponent.self) else {
      fatalError("A InputComponent's entity must have a RenderComponent")
    }
    return renderComponent
  }
  
  var detectComponent: DetectComponent {
    guard let detectComponent: DetectComponent = entity?.componentForClass(DetectComponent.self) else {
      fatalError("A InputComponent's entity must have a DetectComponent")
    }
    return detectComponent
  }
  
  var relateComponent: RelateComponent {
    guard let relateComponent = entity?.componentForClass(RelateComponent.self) else {
      fatalError("A InputComponent's entity must have a RelateComponent")
    }
    return relateComponent
  }
  
  var moveableDirections: [MoveDirection]?
  
  var firstTouchPosition: CGPoint?
  
  let MIN_MOVE_DISTANCE: CGFloat = 5
  
  var inputState = InputState() {
    didSet {
      applyInputState(inputState)
    }
  }
  
  var spritesLayer: SKNode!
  
  var centerNode: EntityNode?
  
  func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    //need to check is rotating
    // mat be can when rotating the moveableDirections return empty
    moveableDirections = detectComponent.moveableDirections()
    guard moveableDirections != nil  && moveableDirections!.count != 0 && touches.first != nil else { return }
    
    spritesLayer = renderComponent.node.parent!
    firstTouchPosition = touches.first!.locationInNode(spritesLayer)
  }
  
  func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard firstTouchPosition != nil && moveableDirections != nil else { return }
    setUpInputStateWith(touches.first!.locationInNode(spritesLayer))
  }
  
  func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    restInputState()
  }
  
  func setUpInputStateWith(movePosition: CGPoint) {
    if inputState.isRotating == false {
      let vector = movePosition - firstTouchPosition!
      for direction in moveableDirections! {
        if direction.targetDistance(vector) > MIN_MOVE_DISTANCE {
          let detectDistance = GameplayConfiguration.Rod.height/2.0 + GameplayConfiguration.RotationPoint.radius
          if let pointNode = detectNode(renderComponent.node, inDirection: direction, detectDistance: detectDistance) as? EntityNode {
            if let relateComponent = pointNode.entity.componentForClass(RelateComponent.self), stateMatchine = pointNode.entity.componentForClass(IntelligenceComponent.self)?.stateMachine where centerNode == nil {
              //TODO: May need to update
              stateMatchine.enterState(PointRotatingState)
              centerNode = pointNode
              let info = relateComponent.makeCompoundNode()
              inputState = InputState(touchPosition: movePosition, centerPosition: info.1, moveNode: info.0, isRotating: true)
            }
          }
          break
        }
      }
    }else {
      inputState.touchPosition = movePosition
    }
  }
  
  func restInputState() {
    guard let centerNode = centerNode else { return }
//    if let relateComponent = centerNode.entity.componentForClass(RelateComponent.self) {
//      relateComponent.decompound()
//    }
    inputState = InputState.initialSate
    centerNode.entity.componentForClass(RelateComponent.self)?.decompound()
    //FIXME: Maybe maybe right ....
    centerNode.entity.componentForClass(MoveComponent.self)?.restRotation({ [unowned self] in
      self.moveableDirections = nil
      self.centerNode = nil
    })
  }
  
  func applyInputState(state: InputState) {
    if let moveComponent = entity?.componentForClass(MoveComponent.self) {
        moveComponent.isRotating = state.isRotating
        moveComponent.moveNode = state.moveNode
        moveComponent.lastTouchPosition = state.touchPosition
        moveComponent.centerPosition = state.centerPosition
    }
  }
  
  
}
