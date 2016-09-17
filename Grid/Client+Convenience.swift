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
  
  func shareLevel(_ nodes: [SKNode], levelName: String?, completionHandler: @escaping (Int)->()) -> URLSessionTask {
    let task = taskForPostMethod(Client.Methods.ShareLevel, jsonBody: getLevelDate(nodes, levelName: levelName)) { data in
      let json = JSON(data: data)
      let levelId = json[JSONBodyKeys.LevelId].int!
      completionHandler(levelId)
    }
    return task
  }
  
  
  fileprivate func getLevelDate(_ nodes: [SKNode], levelName: String?) -> Dictionary<String, AnyObject> {
    let levelName = levelName == nil ? "DIY" : levelName!
    let nodesInfo: [Dictionary<String, AnyObject>] = nodes.map { node in
      let dic:Dictionary<String, AnyObject> = [Client.JSONBodyKeys.NodeName: node.name! as AnyObject, "position": NSStringFromCGPoint(node.position) as AnyObject, "zRotation": NSNumber(value: Double(node.zRotation) as Double), "nodeType": NodeType(nodeName: node.name).rawValue as AnyObject]
      return dic
    }
    return ["level": ["name": levelName], "nodes": nodesInfo]
  }
  
  
  func getLevelDetail(_ levelid: Int, completionHandler:@escaping (_ sceen: SKScene)->()) -> URLSessionTask {
    let task = taskForGetMethod(Client.Methods.GetLevelDeail, parameters: [Client.ParameterKeys.LevelId: levelid]) { data in
      let json = JSON(data: data)
      let nodes = json[Client.JSONBodyKeys.Nodes]
      let nodesData: [Dictionary<String, String>] = nodes.map { node in
        let nodeInfo = node.1
        return ["name": nodeInfo[JSONBodyKeys.NodeName].string!, "position": nodeInfo[Client.JSONBodyKeys.Position].string!,
          "zRotation": String(nodeInfo[Client.JSONBodyKeys.ZRotation].number!), "type": nodeInfo[Client.JSONBodyKeys.Type].string!]
      }
      let scene = LevelEditPlayScene.editSceneFromNodesData(nodesData, sceneType: .sharePlay(levelid))!
      scene.scaleMode = .aspectFill
      completionHandler(sceen: scene)
    }
    return task
  }
  
  func likeLevel(_ levelid: Int, completionHandler: @escaping ()->()) {
    let _ = taskForPostMethod(Client.Methods.LikeLevel, jsonBody: [Client.JSONBodyKeys.LevelId: levelid]) { data in
      let json = JSON(data: data)
      if let result = json[Client.JSONBodyKeys.Result].string , result == Client.JSONBodyValues.Success {
        completionHandler()
      }else {
//        HUD.flash(.LabeledError(title: "Error Happened", subtitle: "Try again"), delay: 1.3)
      }
    }
  }
  
  func getLvelLikeCount(_ levelid: Int, completionHandler: @escaping (Int)->()) {
    let _ = taskForGetMethod(Client.Methods.LikeCount, parameters: ["levelid": levelid]) { data in
      let jsonBody = JSON(data: data)
      let likesCount = jsonBody[Client.JSONBodyKeys.LevelLikesCount].int!
      completionHandler(likesCount)
    }
  }
  
  func levelWin(_ levelid: Int, completionHandler: @escaping ()->()) {
    let _ = taskForPostMethod(Client.Methods.LevelWin, jsonBody: [Client.JSONBodyKeys.LevelId: levelid]) { data in
      let json = JSON(data)
      if let result = json[Client.JSONBodyKeys.Result].string , result == Client.JSONBodyValues.Success {
        completionHandler()
      }
    }
  }
  
  func levelLose(_ levelid: Int, completionHandler: @escaping ()->()) {
    let _ = taskForPostMethod(Client.Methods.LevelLose, jsonBody: [Client.JSONBodyKeys.LevelId: levelid]) { data in
      let json = JSON(data)
      if let result = json[Client.JSONBodyKeys.Result].string , result == Client.JSONBodyValues.Success {
        completionHandler()
      }
    }
  }
  
  func getLevelWinTimes(_ levelid: Int, completionHandler: @escaping (Int)->()) {
    let _ = taskForGetMethod(Client.Methods.GetLevelWinTimes, parameters: ["levelid": levelid]) { data in
      let jsonBody = JSON(data: data)
      let winTimes = jsonBody[Client.JSONBodyKeys.LevelWinTimes].int!
      completionHandler(winTimes)
    }
  }
  
  func getLevelLoseTimes(_ levelid: Int, completionHandler: @escaping (Int)->()) {
    let _ = taskForGetMethod(Client.Methods.GetLevelLoseTimes, parameters: ["levelid": levelid]) { data in
      let jsonBody = JSON(data: data)
      let lostTimes = jsonBody[Client.JSONBodyKeys.LevelLoseTimes].int!
      completionHandler(lostTimes)
    }
  }
  
  func getPlayLevelInfo(_ levelid: Int, completionHandler:@escaping ([String: Int])->()) -> URLSessionTask{
    let task = taskForGetMethod(Client.Methods.GetLevelPlayInfo, parameters: ["levelid": levelid]) { data in
      let jsonBody = JSON(data: data)
      if let winTimes = jsonBody[Client.JSONBodyKeys.LevelWinTimes].int, let lostTimes = jsonBody[Client.JSONBodyKeys.LevelLoseTimes].int, let likesCount = jsonBody[Client.JSONBodyKeys.LevelLikesCount].int {
        let playInfo = [Client.JSONBodyKeys.LevelWinTimes: winTimes, Client.JSONBodyKeys.LevelLoseTimes: lostTimes, Client.JSONBodyKeys.LevelLikesCount: likesCount]
        completionHandler(playInfo)
      }
    }
    return task
  }
  
}
