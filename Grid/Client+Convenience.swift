//
//  Client+Convenience.swift
//  Grid
//
//  Created by Nero Zuo on 16/4/4.
//  Copyright © 2016年 Nero. All rights reserved.
//

import Foundation
import SpriteKit

extension Client {
  
  func shareLevel(nodes: [SKNode], levelName: String?) {
    let task = taskForPostMethod(Client.Methods.ShareLevel, parameters: getLevelDate(nodes, levelName: levelName)) { data in
      
    }
  }
  
  
  func getLevelDate(nodes: [SKNode], levelName: String?) -> Dictionary<String, AnyObject> {
    let levelName = levelName == nil ? "DIY" : levelName!
    let nodesInfo: [Dictionary<String, AnyObject>] = nodes.map { node in
      let dic:Dictionary<String, AnyObject> = [Client.JSONBodyKeys.NodeName: node.name!, "position": NSStringFromCGPoint(node.position), "zRotation": NSNumber(double: Double(node.zRotation)), "nodeType": NodeType(nodeName: node.name).rawValue]
      return dic
    }
    return ["level": ["name": levelName], "nodes": nodesInfo]
  }
  
}