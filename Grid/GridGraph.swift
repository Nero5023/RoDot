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
      let previousRods = vertexs[index].rods
      vertexs[index].rods.removeAll()
      
      updateVertexRodsWithIndex(index)
      let presentRods = vertexs[index].rods
      let sameRods = presentRods.intersect(previousRods)
      let changedRods = previousRods.subtract(sameRods)
      if changedRods.count == 1 {
        changedRods.first!.pointNodes = Set(changedRods.first!.pointNodes.filter({$0 != pointNode}))
      }
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
        rod.pointNodes = Set(rod.pointNodes.filter({ $0 != node }))
      }
    }else {
      node.state.enterState(Unlocked)
      for rod in rods {
        rod.pointNodes.insert(node)
      }
    }
  }
  
  //According to the index, append the rods around the pointNode
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
  
  // Traverse the rods around the rotationPointNode
  func traverseRelatedRodsWithRotationNode(rotationPointNode: RotationPointNode, block: RodNode -> Void) {
    if let index = indexOfNode(rotationPointNode) {
      let rods = vertexs[index].rods
      for rod in rods {
        block(rod)
      }
    }
  }
  
  //Attach the fixed joint to the rods and point
  func attachJointFixToPointNode(node: RotationPointNode, atScene scene: SKScene) {
    traverseRelatedRodsWithRotationNode(node, block: { rod in
      let fixJoint = SKPhysicsJointFixed.jointWithBodyA(rod.physicsBody!, bodyB: node.physicsBody!, anchor: scene.convertPoint(node.position, fromNode: node.parent!))
      scene.physicsWorld.addJoint(fixJoint)
      rod.physicsBody?.dynamic = true
    })
  }
  
  // Like the method like above
  func setAllRelatedRodsDynamicWithRotationNode(node: RotationPointNode) {
    traverseRelatedRodsWithRotationNode(node, block: { rod in
      rod.physicsBody?.dynamic = false
    })
  }
  
  func makeCompoundNode(withPointNode pointNode: RotationPointNode) -> SKSpriteNode? {
    guard let index = indexOfNode(pointNode) else { return nil }
    let compound = SKSpriteNode()
    vertexs[index].point.removeFromParent()
    compound.addChild(vertexs[index].point)
    for rod in vertexs[index].rods {
      rod.removeFromParent()
      compound.addChild(rod)
    }
    var bodies = vertexs[index].rods.map { $0.physicsBody! }
    bodies.append(vertexs[index].point.physicsBody!)
    compound.physicsBody = SKPhysicsBody(bodies: bodies)
    
    return compound
  }

  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: kPointNodeCheckNotification, object: nil)
  }
  
}
