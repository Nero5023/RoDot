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
  
  func shareLevel(nodes: [SKNode], levelName: String?, completionHandler: (Int)->()) -> NSURLSessionTask {
    let task = taskForPostMethod(Client.Methods.ShareLevel, jsonBody: getLevelDate(nodes, levelName: levelName)) { data in
      let json = JSON(data: data)
      let levelId = json[JSONBodyKeys.LevelId].int!
      completionHandler(levelId)
    }
    return task
  }
  
  
  private func getLevelDate(nodes: [SKNode], levelName: String?) -> Dictionary<String, AnyObject> {
    let levelName = levelName == nil ? "DIY" : levelName!
    let nodesInfo: [Dictionary<String, AnyObject>] = nodes.map { node in
      let dic:Dictionary<String, AnyObject> = [Client.JSONBodyKeys.NodeName: node.name!, "position": NSStringFromCGPoint(node.position), "zRotation": NSNumber(double: Double(node.zRotation)), "nodeType": NodeType(nodeName: node.name).rawValue]
      return dic
    }
    return ["level": ["name": levelName], "nodes": nodesInfo]
  }
  
  
  func getLevelDetail(levelid: Int, completionHandler:(sceen: SKScene)->()) -> NSURLSessionTask {
    let task = taskForGetMethod(Client.Methods.GetLevelDeail, parameters: [Client.ParameterKeys.LevelId: levelid]) { data in
      let json = JSON(data: data)
      let nodes = json[Client.JSONBodyKeys.Nodes]
      let nodesData: [Dictionary<String, String>] = nodes.map { node in
        let nodeInfo = node.1
        return ["name": nodeInfo[JSONBodyKeys.NodeName].string!, "position": nodeInfo[Client.JSONBodyKeys.Position].string!,
          "zRotation": String(nodeInfo[Client.JSONBodyKeys.ZRotation].number!), "type": nodeInfo[Client.JSONBodyKeys.Type].string!]
      }
      let scene = LevelEditPlayScene.editSceneFromNodesData(nodesData, sceneType: .sharePlay)!
      scene.scaleMode = .AspectFill
      completionHandler(sceen: scene)
    }
    return task
  }
  
  func likeLevel(levelid: Int, completionHandler: ()->()) {
    let _ = taskForPostMethod(Client.Methods.LikeLevel, jsonBody: [Client.JSONBodyKeys.LevelId: levelid]) { data in
      let json = JSON(data: data)
      if let result = json[Client.JSONBodyKeys.Result].string where result == Client.JSONBodyValues.Success {
        completionHandler()
      }else {
        HUD.flash(.LabeledError(title: "Error Happened", subtitle: "Try again"), delay: 1.3)
      }
    }
  }
  
}