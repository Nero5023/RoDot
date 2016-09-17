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

let BackgroundMusicEabledKey = "BackgroundMusicEabled"
let SoundEffertEabledKey = "SoundEffertEabled"

final class SceneManager {
  
  // MARK: Propreties
  
  static let sharedInstance = SceneManager()
  
  var presentingView: SKView!
  
  var startScene: StartScene!
  
  var managedContext: NSManagedObjectContext!
  
  // Need to change
  var presentingController: UIViewController!
  
  // Scene logic method
  
  func showLevelScene(_ level: Int) {
    let levelScene = LevelScene.level(level)
    levelScene?.scaleMode = .aspectFill
    presentingView.presentScene(levelScene)
  }
  
  func showLevelScene(_ theme: ThemeType, level: Int) {
    let levelScene = LevelScene.themeLevel(theme, levelNum: level)
    levelScene?.scaleMode = .aspectFill
    presentingView.presentScene(levelScene)
  }
  
  func backToStartScene() {
    presentingView.presentScene(startScene)
  }
  
  // 
  
  func addRotateCountNodes(_ toNode: SKSpriteNode, rotateCount: Int) -> [SKSpriteNode] {
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
  
  func addBubbles(_ toNode: SKSpriteNode, rotatableRodCount: Int) {
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
  
  func animationBubble(_ inNode: SKSpriteNode, isClockwise: Bool) {
    let animationDuration: TimeInterval = 1
    
    let bubbles = inNode.children.filter{ $0.name == "bubble" }
    for (index, bubble) in bubbles.enumerated() {
      //      let path = UIBezierPath(ovalInRect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 32, height: 32)))
      let path = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: GameplayConfiguration.bubbleOrbitRadius, startAngle: CGFloat(0).degreesToRadians(), endAngle: CGFloat(360).degreesToRadians(), clockwise: false)
      //      path.applyTransform(CGAffineTransformMakeRotation(90))
      bubble.position = CGPoint(x: GameplayConfiguration.bubbleOrbitRadius, y: 0)
      // this is the colckwise animation
      let rotateAction = SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, duration: animationDuration)
      var foreverRotation = SKAction.repeatForever(rotateAction)
      if !isClockwise {
        foreverRotation = SKAction.repeatForever(rotateAction.reversed())
      }
      
      let waitDuration = animationDuration/TimeInterval(bubbles.count)*TimeInterval(index)
      let waitAction = SKAction.wait(forDuration: waitDuration)
      bubble.run(SKAction.sequence([waitAction, foreverRotation]))
    }
  }
  
  func saveLevelData(_ nodes: [SKNode], levelName: String?) -> String {
    let nodesSet = NSMutableSet(capacity: nodes.count)
    let nodeEntity = NSEntityDescription.entity(forEntityName: "Node", in: managedContext)
    
    for node in nodes {
      let nodeData = Node(entity: nodeEntity!, insertInto: managedContext)
      nodeData.name = node.name
      nodeData.type = NodeType(nodeName: node.name).rawValue
      nodeData.position = NSStringFromCGPoint(node.position)
      nodeData.zRotation = NSNumber(value: Double(node.zRotation) as Double)
      nodesSet.add(nodeData)
    }
    
    let levelEntity = NSEntityDescription.entity(forEntityName: "Level", in: managedContext)
    let levelData = Level(entity: levelEntity!, insertInto: managedContext)
    levelData.date = Date()
    levelData.name = levelName
    levelData.nodes = nodesSet
    
    do {
      try managedContext.save()
    }catch let error as NSError {
      print("Can't save, error:\(error)")
    }
    return "\(levelData.objectID)"
  }
  
  
  
  
  func fetchFirstLevel() -> [Node] {
    let levelFetch = NSFetchRequest(entityName: "Level")
    do {
      let levels = try managedContext.fetch(levelFetch) as! [Level]
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
      let levels = try managedContext.fetch(levelFetch) as! [Level]
      return levels
    }catch let error as NSError {
      print("Error: \(error)")
    }
    return []
  }
  
  
  
  
  
  // TODO: Change it
  
  func getLevelDate(_ nodes: [SKNode], levelName: String?) -> Dictionary<String, AnyObject> {
    let levelName = levelName == nil ? "DIY" : levelName!
    let nodesInfo: [Dictionary<String, AnyObject>] = nodes.map { node in
      let dic:Dictionary<String, AnyObject> = ["name": node.name! as AnyObject, "position": NSStringFromCGPoint(node.position) as AnyObject, "zRotation": NSNumber(value: Double(node.zRotation) as Double), "nodeType": NodeType(nodeName: node.name).rawValue as AnyObject]
      return dic
    }
    return ["level": ["name": levelName], "nodes": nodesInfo]
  }
  
  func shareLevel(_ nodes: [SKNode], levelName: String?) {
//    let urlString = "http://localhost:8080/newLevel/"
    let urlString = "https://rodot.me/newLevel/"
    let url = URL(string: urlString)
    let session = URLSession.shared
    let request = NSMutableURLRequest(url: url!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let parmas = getLevelDate(nodes, levelName: levelName)
    do {
      
      request.httpBody = try JSONSerialization.data(withJSONObject: parmas, options: [])
    }catch let error as NSError {
      print("error:\(error)")
    }
    
    let task = session.dataTask(with: request, completionHandler: { data, response, error in
//      print("123")
//      print("313")
      let json = JSON(data: data!)
      let levelid = json["levelid"].int
      print((response as? HTTPURLResponse)?.statusCode)
      print(levelid)
      let result = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)
      print(result as! NSDictionary)
    }) 
    task.resume()
  }
  
  func getLevelFromWebServer(){
    let levelId = 1
    let urlString = "http://localhost:8080/level/" + "\(levelId)"
    let url = URL(string: urlString)
    let session = URLSession.shared
    let request = NSMutableURLRequest(url: url!)
    request.httpMethod = "GET"
    //    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let task = session.dataTask(with: request, completionHandler: { data, response, error in
      
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
      let scene = LevelEditPlayScene.editSceneFromNodesData(nodesData, sceneType: .sharePlay(levelId))
      scene?.scaleMode = .aspectFill
      SceneManager.sharedInstance.presentingView.presentScene(scene)
    }) 
    task.resume()
  }
  
  func backgroundMusicEabled() -> Bool {
    return UserDefaults.standard.bool(forKey: BackgroundMusicEabledKey)
  }
  
  func soundEffertMusicEabled() -> Bool {
    return UserDefaults.standard.bool(forKey: SoundEffertEabledKey)
  }
  
  func setBackgroundMuscicEabled(_ eabled: Bool) {
    if eabled {
      SKTAudio.sharedInstance().resumeBackgroundMusic()
    }else {
      SKTAudio.sharedInstance().pauseBackgroundMusic()
    }
    UserDefaults.standard.set(eabled, forKey: BackgroundMusicEabledKey)
  }
  
  func setSoundEffertEabled(_ eabled: Bool) {
    UserDefaults.standard.set(eabled, forKey: SoundEffertEabledKey)
  }
  
}
