//
//  GridGraph.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/10.
//  Copyright © 2016年 Nero. All rights reserved.
//

import Foundation
import SpriteKit

struct Vertex {
  var point: RotationPointNode
  var rods: Set<RodNode>
}

class GridGraph {
  var vertexs: [Vertex]
  
//  init?(points: [RotationPointNode], rods: [[RodNode]]) {
//    guard points.count == rods.count else {
//      return nil
//    }
//    self.vertexs = [Vertex]()
//    for (i, point) in points.enumerate() {
//      let vertex = Vertex(point: point, rods: Set(rods[i]))
//      self.vertexs.append(vertex)
//    }
//    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("checkPoint:"), name: kPointNodeCheckNotification, object: nil)
//  }
  
  init() {
    self.vertexs = [Vertex]()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("checkPoint:"), name: kPointNodeCheckNotification, object: nil)
  }
  
  //NSNotification selector check the point node
  @objc func checkPoint(notification: NSNotification) {
    guard let pointNode = notification.object as? RotationPointNode else { return }
    
    if let index = indexOfNode(pointNode) { //If the vertexs has already had the vertex which contain pointNode
      // Double Check
      if vertexs[index].point != pointNode { return }
      vertexs[index].rods.removeAll()
      
      updateVertexRodsWithIndex(index)
      changePointNodeStateWithRods(vertexs[index].rods, node: pointNode)
    }else { // if pointNode not in the vertexs
      let vertex = Vertex(point: pointNode, rods: [])
      self.vertexs.append(vertex)
      
      updateVertexRodsWithIndex(self.vertexs.count-1)
      changePointNodeStateWithRods(vertexs.last!.rods, node: pointNode)
    }

    
  }
  
  
  //Get the index of the node which in vertex in vertexs  O(n)
  func indexOfNode(node: RotationPointNode) -> Int? {
    var index: Int?
    for (i, vertex) in vertexs.enumerate() {
      if vertex.point == node {
        index = i
      }
    }
    return index
  }
  
  
  // Change the node state with rods count
  func changePointNodeStateWithRods(rods: Set<RodNode>, node: RotationPointNode) {
    if rods.count == 4 {
      node.state.enterState(Locked)
      for rod in rods {
        rod.pointNodes.removeAll()
      }
    }else {
      node.state.enterState(Unlocked)
      for rod in rods {
        rod.pointNodes.append(node)
      }
    }
  }
  
  
  func updateVertexRodsWithIndex(index: Int) {
    guard vertexs[index].rods.count == 0  && index >= 0 && index < vertexs.count else { return }
    let tags = [(1, 0), (0, 1), (0, -1), (-1, 0)]
    let pointNode = vertexs[index].point
    for tag in tags {
      let targetPosition = CGPoint(
        x: pointNode.position.x + CGFloat(tag.0)*pointNode.size.width,
        y: pointNode.position.y + CGFloat(tag.1)*pointNode.size.width)
      if let rodNode = pointNode.parent!.nodeAtPoint(targetPosition) as? RodNode {
        vertexs[index].rods.insert(rodNode)
      }
    }
  }
  
  //Attach the fixed joint to the rods and point
  func attachJointFixToPointNode(node: RotationPointNode, atScene scene: SKScene) {
    if let index = indexOfNode(node) {
      let rods = vertexs[index].rods
      for rod in rods {
        let fixJoint = SKPhysicsJointFixed.jointWithBodyA(rod.physicsBody!, bodyB: node.physicsBody!, anchor: scene.convertPoint(node.position, fromNode: node.parent!))
        scene.physicsWorld.addJoint(fixJoint)
        rod.physicsBody?.dynamic = true
      }
    }
  }
  
  // Like the method like above
  func setAllRelatedRodsDynamicWithRotationNode(node: RotationPointNode) {
    if let index = indexOfNode(node) {
      let rods = vertexs[index].rods
      for rod in rods {
        rod.physicsBody?.dynamic = false
      }
    }
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: kPointNodeCheckNotification, object: nil)
  }
  
}
