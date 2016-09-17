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
    var isTranslation = false
    
    init() { }
    
    init(touchPosition: CGPoint, centerPosition: CGPoint, moveNode: SKSpriteNode, isRotating: Bool) {
      self.touchPosition = touchPosition
      self.centerPosition = centerPosition
      self.moveNode = moveNode
      self.isRotating = isRotating
      self.isTranslation = false
    }
    
    init(touchPosition: CGPoint, centerPosition: CGPoint, moveNode: SKSpriteNode, isTranslation: Bool) {
      self.touchPosition = touchPosition
      self.centerPosition = centerPosition
      self.moveNode = moveNode
      self.isTranslation = isTranslation
      self.isRotating = false
    }
    
    static let initialSate = InputState()
  }
  
  // MARK: Properties
  
  var renderComponent: RenderComponent {
    guard let renderComponent = entity?.component(ofType: RenderComponent.self) else {
      fatalError("A InputComponent's entity must have a RenderComponent")
    }
    return renderComponent
  }
  
  var detectComponent: DetectComponent {
    guard let detectComponent: DetectComponent = entity?.component(ofType: DetectComponent.self) else {
      fatalError("A InputComponent's entity must have a DetectComponent")
    }
    return detectComponent
  }
  
  var relateComponent: RelateComponent {
    guard let relateComponent = entity?.component(ofType: RelateComponent.self) else {
      fatalError("A InputComponent's entity must have a RelateComponent")
    }
    return relateComponent
  }
  
  var moveableDirections: [MoveDirection]?
  
  var firstTouchPosition: CGPoint?
  
  let MIN_MOVE_DISTANCE: CGFloat = 3
  
  var inputState = InputState() {
    didSet {
      applyInputState(inputState)
    }
  }
  
  var spritesLayer: SKNode!
  
  var centerNode: EntityNode?
  
  // MARK: Touch event
  
  func touchesBegan(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
    //need to check is rotating
    // mat be can when rotating the moveableDirections return empty
    moveableDirections = detectComponent.moveableDirections()
    guard moveableDirections != nil  && moveableDirections!.count != 0 && touches.first != nil else { return }
    self.centerNode = nil
    spritesLayer = renderComponent.node.parent!
    firstTouchPosition = touches.first!.location(in: spritesLayer)
  }
  
  func touchesMoved(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard firstTouchPosition != nil && moveableDirections != nil else { return }
    setUpInputStateWith(touches.first!.location(in: spritesLayer))
  }
  
  func touchesEnded(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
    restInputState()
  }
  
  // MARK: Convenience Methods
  
  func setUpInputStateWith(_ movePosition: CGPoint) {
    if inputState.isRotating == false && inputState.isTranslation == false{
      let vector = movePosition - firstTouchPosition!
      for direction in moveableDirections! {
        if direction.targetDistance(vector) > MIN_MOVE_DISTANCE {
          let detectDistance = GameplayConfiguration.Rod.height/2.0 + GameplayConfiguration.RotationPoint.radius
          if let pointNode = detectNode(renderComponent.node, inDirection: direction, detectDistance: detectDistance) as? EntityNode {
            if let relateComponent = pointNode.entity.component(ofType: RelateComponent.self), let stateMatchine = pointNode.entity.component(ofType: IntelligenceComponent.self)?.stateMachine , centerNode == nil {
              //TODO: May need to update
              centerNode = pointNode
              if stateMatchine.state(forClass: PointRotatingState.self) != nil {
                stateMatchine.enter(PointRotatingState)
                let info = relateComponent.makeCompoundNode()
                inputState = InputState(touchPosition: movePosition, centerPosition: info.1, moveNode: info.0, isRotating: true)
              }
              if stateMatchine.state(forClass: PointTranslatingState.self) != nil {
                
                let targetDistance = GameplayConfiguration.Rod.height + GameplayConfiguration.RotationPoint.radius*2
                // If the node at the targetDistance is not EntityNode, then do nothing
                if let _ = detectNode(renderComponent.node, inDirection: direction, detectDistance: targetDistance) as? EntityNode {
                  return
                }else {
                  stateMatchine.enter(PointTranslatingState)
                  inputState = InputState(touchPosition: movePosition, centerPosition: pointNode.position, moveNode: renderComponent.node, isTranslation: true)
                }
              }
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
    guard let _ = centerNode else { return }
    if inputState.isRotating == true {
      inputState.isRotating = false
      let moveComponent = entity?.component(ofType: MoveComponent.self)
      moveComponent!.setTargetRestPosition()
      
      self.moveableDirections = nil
      self.centerNode = nil
//      inputState = InputState.initialSate
//      centerNode.entity.componentForClass(RelateComponent.self)?.decompound()
//      centerNode.entity.componentForClass(MoveComponent.self)?.restRotation({ [unowned self] in
//        self.moveableDirections = nil
//        self.centerNode = nil
//        })
    }
    if inputState.isTranslation == true {
      inputState.isTranslation = false
      entity?.component(ofType: MoveComponent.self)?.restTranslation({ [unowned self] in
        self.moveableDirections = nil
        self.centerNode = nil
        self.inputState = InputState.initialSate
      })
    }
  }
  
  func applyInputState(_ state: InputState) {
    if let moveComponent = entity?.component(ofType: MoveComponent.self) {
      moveComponent.isRotating = state.isRotating
      moveComponent.moveNode = state.moveNode
      moveComponent.lastTouchPosition = state.touchPosition
      moveComponent.centerPosition = state.centerPosition
      moveComponent.isTranslating = state.isTranslation
    }
  }
  
  
}
