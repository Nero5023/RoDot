//
//  DetectComponent.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/27.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

enum MoveDirection {
  case left, up, right, down
  
  static let allDirections: [MoveDirection] = [.left, .up, .right, .down]
  
  var tag:(Int, Int) {
    switch self {
    case .left:
      return (-1, 0)
    case .right:
      return (1, 0)
    case .up:
      return (0, 1)
    case .down:
      return (0, -1)
    }
  }
  
  func targetDistance(vector: CGPoint) -> CGFloat {
    return CGFloat(self.tag.0)*vector.x + CGFloat(self.tag.1)*vector.y
  }
  
}

class DetectComponent: GKComponent {
  
  // MARK: Properties
  
  var relateComponent: RelateComponent {
    guard let relateComponent = entity?.componentForClass(RelateComponent.self) else {
      fatalError("A DetectComponent's entity must have a RelateComponent")
    }
    return relateComponent
  }
  
  var orientationComponent: OrientationComponent {
    guard let orientationComponent = entity?.componentForClass(OrientationComponent.self) else {
      fatalError("A DetctComponent's entity must have a OrientationComponent")
    }
    return orientationComponent
  }
  
  var renderComponent: RenderComponent {
    guard let renderComponent = entity?.componentForClass(RenderComponent.self) else {
      fatalError("A DetctComponent's entity must have a RenderComponent")
    }
    return renderComponent
  }
  
  // MARK: Actons
  
  //This method is for rod node to decide which direction can be rotate
  func moveableDirections() -> [MoveDirection] {
    var results: [MoveDirection] = []
    let orientation = orientationComponent.direction
    for relateNode in relateComponent.relateNodes {
      if relateNode.entity.componentForClass(IntelligenceComponent.self)?.stateMachine.currentState is PointUnlockedState {
        if orientation == HVDirection.horizontal {
          if relateNode.position.x < renderComponent.node.position.x {
            results.append(.left)
          }else {
            results.append(.right)
          }
        }else {
          if relateNode.position.y < renderComponent.node.position.y {
            results.append(.down)
          }else {
            results.append(.up)
          }
        }
      }
    }
    return results
  }
  
}
