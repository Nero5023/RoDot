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
  
  static let sharedInstance = GridGraph()
  
  fileprivate init() {
    self.vertexs = [Vertex]()
    NotificationCenter.default.addObserver(self, selector: #selector(GridGraph.checkPoint(_:)), name: NSNotification.Name(rawValue: kPointNodeCheckNotification), object: nil)
  }
  
  //NSNotification selector check the point node
  @objc func checkPoint(_ notification: Notification) {
    guard let pointNode = notification.object as? RotationPointNode else { return }
    
    if let index = indexOfNode(pointNode) { //If the vertexs has already had the vertex which contain pointNode
      // Double Check
      if vertexs[index].point != pointNode { return }
      let previousRods = vertexs[index].rods
      vertexs[index].rods.removeAll()
      
      updateVertexRodsWithIndex(index)
      let presentRods = vertexs[index].rods
      let sameRods = presentRods.intersection(previousRods)
      let changedRods = previousRods.subtracting(sameRods)
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
  func indexOfNode(_ node: RotationPointNode) -> Int? {
    var index: Int?
    for (i, vertex) in vertexs.enumerated() {
      if vertex.point == node {
        index = i
      }
    }
    return index
  }
  
  
  // Change the node state with rods count
  func changePointNodeStateWithRods(_ rods: Set<RodNode>, node: RotationPointNode) {
    if rods.count == 4 {
      node.state.enter(Locked)
      for rod in rods {
        rod.pointNodes = Set(rod.pointNodes.filter({ $0 != node }))
      }
    }else {
      node.state.enter(Unlocked)
      for rod in rods {
        rod.pointNodes.insert(node)
      }
    }
  }
  
  //According to the index, append the rods around the pointNode
  func updateVertexRodsWithIndex(_ index: Int) {
    guard vertexs[index].rods.count == 0  && index >= 0 && index < vertexs.count else { return }
    let tags = [(1, 0), (0, 1), (0, -1), (-1, 0)]
    let pointNode = vertexs[index].point
    for tag in tags {
      let targetPosition = CGPoint(
        x: pointNode.position.x + CGFloat(tag.0)*pointNode.size.width,
        y: pointNode.position.y + CGFloat(tag.1)*pointNode.size.width)
      if let rodNode = pointNode.parent!.atPoint(targetPosition) as? RodNode {
        vertexs[index].rods.insert(rodNode)
      }
    }
  }
  
  // Traverse the rods around the rotationPointNode
  func traverseRelatedRodsWithRotationNode(_ rotationPointNode: RotationPointNode, block: (RodNode) -> Void) {
    if let index = indexOfNode(rotationPointNode) {
      for rod in vertexs[index].rods {
        block(rod)
      }
    }
  }
  
  //Attach the fixed joint to the rods and point
  func attachJointFixToPointNode(_ node: RotationPointNode, atScene scene: SKScene) {
    guard let index = indexOfNode(node) else { return }
    print("vertexs[index].rods.count:\(vertexs[index].rods.count)")
    traverseRelatedRodsWithRotationNode(node, block: { rod in
      let fixJoint = SKPhysicsJointFixed.joint(withBodyA: rod.physicsBody!, bodyB: node.physicsBody!, anchor: scene.convert(node.position, from: node.parent!))
      rod.physicsBody!.isDynamic = true
      scene.physicsWorld.add(fixJoint)
    })
  }
  
  // Like the method like above
  func setAllRelatedRodsDynamicWithRotationNode(_ node: RotationPointNode) {
    traverseRelatedRodsWithRotationNode(node, block: { rod in
      rod.physicsBody?.isDynamic = false
    })
  }
  
  // Return the compoundNode accroding the center pointNode
  func makeCompoundNode(withPointNode pointNode: RotationPointNode) -> SKSpriteNode? {
    guard let index = indexOfNode(pointNode) else { return nil }
    let compound = SKSpriteNode()
    vertexs[index].point.removeFromParent()
    vertexs[index].point.physicsBody = nil
    compound.addChild(vertexs[index].point)
    for rod in vertexs[index].rods {
      rod.removeFromParent()
      rod.physicsBody = nil
      compound.addChild(rod)
    }
    
    var bodies = [SKPhysicsBody]()
    for rod in vertexs[index].rods {
      if abs(rod.zRotation) < 0.1 || abs(abs(rod.zRotation) - π) < 0.1 {
        bodies.append(SKPhysicsBody(rectangleOf: CGSize(width: 22, height: rod.size.height-8), center: rod.position))
      }else {
        bodies.append(SKPhysicsBody(rectangleOf: CGSize(width: rod.size.height-8, height: 22), center: rod.position))
      }
    }
    
    bodies.append(SKPhysicsBody(circleOfRadius: vertexs[index].point.size.width/4, center: vertexs[index].point.position))
    compound.physicsBody = SKPhysicsBody(bodies: bodies)
    compound.physicsBody!.categoryBitMask = PhysicsCategory.Rod
    compound.physicsBody!.collisionBitMask = PhysicsCategory.Ball
    return compound
  }
  
  
  func getAllRotatingNodes(withPointNode pointNode: RotationPointNode) -> [SKSpriteNode] {
    guard let index = indexOfNode(pointNode) else { return [] }
    var rotatingNodes: [SKSpriteNode] = Array(vertexs[index].rods)
    rotatingNodes.append(vertexs[index].point)
    return rotatingNodes
  }

  
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kPointNodeCheckNotification), object: nil)
  }
  
}
