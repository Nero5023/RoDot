//
//  SceneManager.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/26.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreData

final class SceneManager {
  
  // MARK: Propreties
  
  static let sharedInstance = SceneManager()
  
  var presentingView: SKView!
  
  var startScene: StartScene!
  
  var managedContext: NSManagedObjectContext!
  
  // Need to change
  var presentingController: UIViewController!
  
  // Scene logic method
  
  func showLevelScene(level: Int) {
    let levelScene = LevelScene.level(level)
    levelScene?.scaleMode = .AspectFill
    presentingView.presentScene(levelScene)
  }
  
  func backToStartScene() {
    presentingView.presentScene(startScene)
  }
  
  // 
  
  func addRotateCountNodes(toNode: SKSpriteNode, rotateCount: Int) -> [SKSpriteNode] {
    var rotateCountNodes = [SKSpriteNode]()
    rotateCountNodes.reserveCapacity(rotateCount)
    var zRotation: CGFloat = 90
    if rotateCount == 2 {
      zRotation = 180
    }
    for i in 0..<rotateCount {
      let node = SKSpriteNode(imageNamed: "rotatecount")
      node.name = "rotatecount"
      node.zRotation = CGFloat(i) * zRotation.degreesToRadians()
      rotateCountNodes.append(node)
      toNode.addChild(node)
    }
    return rotateCountNodes
  }
  
  func addBubbles(toNode: SKSpriteNode, rotatableRodCount: Int) {
    var zRotateion:CGFloat = 90
    if rotatableRodCount == 3 {
      zRotateion = 120
    }else if rotatableRodCount == 2 {
      zRotateion = 180
    }
    for i in 0..<rotatableRodCount {
      let bubble = SKSpriteNode(texture: SKTexture(imageNamed: "bubble"))
      let angle = (CGFloat(i) * zRotateion).degreesToRadians()
      bubble.position = CGPoint(x: sin(angle)*GameplayConfiguration.bubbleOrbitRadius, y: cos(angle)*GameplayConfiguration.bubbleOrbitRadius)
      bubble.name = "bubble"
      bubble.zPosition = toNode.zPosition + 10
      toNode.addChild(bubble)
    }
  }
  
  func animationBubble(inNode: SKSpriteNode, isClockwise: Bool) {
    let animationDuration: NSTimeInterval = 1
    
    let bubbles = inNode.children.filter{ $0.name == "bubble" }
    for (index, bubble) in bubbles.enumerate() {
      //      let path = UIBezierPath(ovalInRect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 32, height: 32)))
      let path = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: GameplayConfiguration.bubbleOrbitRadius, startAngle: CGFloat(0).degreesToRadians(), endAngle: CGFloat(360).degreesToRadians(), clockwise: false)
      //      path.applyTransform(CGAffineTransformMakeRotation(90))
      
      // this is the colckwise animation
      let rotateAction = SKAction.followPath(path.CGPath, asOffset: false, orientToPath: false, duration: animationDuration)
      var foreverRotation = SKAction.repeatActionForever(rotateAction)
      if !isClockwise {
        foreverRotation = SKAction.repeatActionForever(rotateAction.reversedAction())
      }
      
      let waitDuration = animationDuration/NSTimeInterval(bubbles.count)*NSTimeInterval(index)
      let waitAction = SKAction.waitForDuration(waitDuration)
      bubble.runAction(SKAction.sequence([waitAction, foreverRotation]))
    }
  }
  
  func saveLevelData(nodes: [SKNode], levelName: String?) {
    let nodesSet = NSMutableSet(capacity: nodes.count)
    let nodeEntity = NSEntityDescription.entityForName("Node", inManagedObjectContext: managedContext)
    
    for node in nodes {
      let nodeData = Node(entity: nodeEntity!, insertIntoManagedObjectContext: managedContext)
      nodeData.name = node.name
      nodeData.type = NodeType(nodeName: node.name).rawValue
      nodeData.position = NSStringFromCGPoint(node.position)
      nodeData.zRotation = NSNumber(double: Double(node.zRotation))
      nodesSet.addObject(nodeData)
    }
    
    let levelEntity = NSEntityDescription.entityForName("Level", inManagedObjectContext: managedContext)
    let levelData = Level(entity: levelEntity!, insertIntoManagedObjectContext: managedContext)
    levelData.date = NSDate()
    levelData.name = levelName
    levelData.nodes = nodesSet
    
    do {
      try managedContext.save()
    }catch let error as NSError {
      print("Can't save, error:\(error)")
    }
  }
  
  func fetchFirstLevel() -> [Node] {
    let levelFetch = NSFetchRequest(entityName: "Level")
    do {
      let levels = try managedContext.executeFetchRequest(levelFetch) as! [Level]
      let nodes = levels.first!.nodes!.map{
        $0 as! Node
      }
      return nodes
    }catch let error as NSError {
      print("Error: \(error)")
    }
    return []
  }
  
  func fetchAllLevels() -> [Level] {
    let levelFetch = NSFetchRequest(entityName: "Level")
    do {
      let levels = try managedContext.executeFetchRequest(levelFetch) as! [Level]
      return levels
    }catch let error as NSError {
      print("Error: \(error)")
    }
    return []
  }
  
  // TODO: Change it
  
  func getLevelDate(nodes: [SKNode], levelName: String?) -> Dictionary<String, AnyObject> {
    let levelName = levelName == nil ? "DIY" : levelName!
    let nodesInfo: [Dictionary<String, AnyObject>] = nodes.map { node in
      let dic:Dictionary<String, AnyObject> = ["name": node.name!, "position": NSStringFromCGPoint(node.position), "zRotation": NSNumber(double: Double(node.zRotation)), "nodeType": NodeType(nodeName: node.name).rawValue]
      return dic
    }
    return ["level": ["name": levelName], "nodes": nodesInfo]
  }
  
  func shareLevel(nodes: [SKNode], levelName: String?) {
//    let urlString = "http://localhost:8080/newLevel/"
    let urlString = "https://rodot.me/newLevel/"
    let url = NSURL(string: urlString)
    let session = NSURLSession.sharedSession()
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let parmas = getLevelDate(nodes, levelName: levelName)
    do {
      
      request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parmas, options: [])
    }catch let error as NSError {
      print("error:\(error)")
    }
    
    let task = session.dataTaskWithRequest(request) { data, response, error in
//      print("123")
//      print("313")
      let json = JSON(data: data!)
      let levelid = json["levelid"].int
      print((response as? NSHTTPURLResponse)?.statusCode)
      print(levelid)
      let result = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
      print(result as! NSDictionary)
    }
    task.resume()
  }
  
  func getLevelFromWebServer(){
    let urlString = "http://localhost:8080/level/1"
    let url = NSURL(string: urlString)
    let session = NSURLSession.sharedSession()
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "GET"
    //    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let task = session.dataTaskWithRequest(request) { data, response, error in
      
      let json = JSON(data: data!)
      
      //      print("reponse:\(response)")
      //      print("error:\(error)")
      let nodes = json["nodes"]
      let nodesData: [Dictionary<String, String>] = nodes.map { node in
        let nodeInfo = node.1
        return ["name": nodeInfo["name"].string!, "position": nodeInfo["position"].string!,
          "zRotation": String(nodeInfo["zRotation"].number!), "type": nodeInfo["type"].string!]
      }
      //        print(nodesData)
      let scene = LevelEditPlayScene.editSceneFromNodesData(nodesData)
      scene?.scaleMode = .AspectFill
      SceneManager.sharedInstance.presentingView.presentScene(scene)
    }
    task.resume()
  }
  
}
