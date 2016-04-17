//
//  LevelEditPlayScene.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/21.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

enum LevelEditPlaySceneType {
  case testPlay    // For when DIYing
  case selfPlay(String?)     // For when playing self designed level, String is the level Name
  case sharePlay(Int)    // For when playing others sharing level, Int is levelid
  
  
}

class LevelEditPlayScene: LevelScene {
  
  // MARK: Properties
  var editPlayScene: LevelEditPlayScene?
  var editScene: LevelEditorScene?
  
  var sceneType: LevelEditPlaySceneType?
  
  lazy var restartButton: SKButtonNode = {
    let restartButton = SKButtonNode(imageNameNormal: "restartbutton", selected: nil)
    restartButton.name = "restartbutton"
    restartButton.zPosition = self.overlayNode.zPosition
    restartButton.actionTouchUpInside =  {
      SKTAudio.sharedInstance().playSoundEffect("menu_click.wav")
      self.newGame()
    }
    restartButton.position = CGPoint(x: self.size.width/2, y: 719)
    return restartButton
  }()
  
  lazy var shareButton: SKButtonNode = {
    let shareButton = SKButtonNode(imageNameNormal: "sharebutton", selected: nil)
    shareButton.name = "sharebutton"
    shareButton.zPosition = self.overlayNode.zPosition
//    restartButton.actionTouchUpInside = self.newGame
    shareButton.actionTouchUpInside = { [unowned self] in
//      SceneManager.sharedInstance.shareLevel(self.editPlayScene!.spritesNode.children, levelName: "DIY")
//      SceneManager.sharedInstance.getLevelFromWebServer()
      
      switch self.sceneType! {
      case .selfPlay(let levelName ):
        self.shareLevel(levelName)
      default:
        self.showEnterLevelNameAlert("Share") { levelName in
          self.shareLevel(levelName)
        }// end for showEnterLevelNameAlert completionHandler
      }

    }
    shareButton.position = CGPoint(x: 1152-300+192, y: 1200)
    return shareButton
  }()
  
  lazy var saveButton: SKButtonNode = {
    let saveButton = SKButtonNode(imageNameNormal: "savebutton", selected: nil)
    saveButton.name = "savebutton"
    saveButton.zPosition = self.overlayNode.zPosition
    saveButton.position = CGPoint(x: 300+192, y: 1200)
    saveButton.actionTouchUpInside = { [unowned self] in
//      
//      let alertController = UIAlertController(title: "Level Name", message: "Plese enter the level name.", preferredStyle: .Alert)
//      
//      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in }
//      let saveAction = UIAlertAction(title: "Save", style: .Default) { action in
//        let loginTextField = alertController.textFields![0] as UITextField
//        SceneManager.sharedInstance.saveLevelData(self.editPlayScene!.spritesNode.children, levelName: loginTextField.text)
//        HUD.flash(.Success, delay: 1.3) { isFinished in
//          SceneManager.sharedInstance.backToStartScene()
//        }
//        
//      }
//      saveAction.enabled = false
//      alertController.addAction(cancelAction)
//      alertController.addAction(saveAction)
//      
//      alertController.addTextFieldWithConfigurationHandler { textField in
//        textField.placeholder = "Name"
//        NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) {
//          nofitication in
//          saveAction.enabled = textField.text != nil
//        }
//        
//      }
//      SceneManager.sharedInstance.presentingController.presentViewController(alertController, animated: true, completion: nil)
//      
      self.showEnterLevelNameAlert("Save") { levelName in
        SceneManager.sharedInstance.saveLevelData(self.editPlayScene!.spritesNode.children, levelName: levelName)
        HUD.flash(.Success, delay: 1.3) { isFinished in
          SceneManager.sharedInstance.backToStartScene()
        }
      }
      
    }
    return saveButton
  }()
  
  lazy var likeButton: SKButtonNode = {
    let likeButton = SKButtonNode(imageNameNormal: "likebutton", selected: nil)
    likeButton.name = "likebutton"
    likeButton.zPosition = self.overlayNode.zPosition
    likeButton.actionTouchUpInside = { [unowned self] in
      guard let sceneType = self.sceneType else { return }
      switch sceneType {
      case .sharePlay(let levelId):
        Client.sharedInstance.likeLevel(levelId) {
          print("like")
          likeButton.isEnabled = false
        }
      default:
        break
      }
    }
    likeButton.position = CGPoint(x: self.size.width/2, y: 1200)
    return likeButton
  }()
  
  // MARK: Class Methods
  class func editScene(rods: [SKSpriteNode], points: [PointButton], ball: SKSpriteNode, destination: SKSpriteNode, transfers: [SKSpriteNode]) -> LevelEditPlayScene? {
    let scene = LevelEditPlayScene(fileNamed: "LevelEdirorScene")
    
    guard let sprites = scene?.childNodeWithName("Sprites") else {
      fatalError("The LevelEditPlayScene must have a node named Sprites")
    }

    var minPoint = CGPoint(x: 10000, y: 10000)
    var maxPoint = CGPoint(x: 0, y: 0)
    for rod in rods {
      if rod.name == "rod" {
        
        let rodNode = copyNode(rod, toType: RodNode.self)
        sprites.addChild(rodNode)
        
        calculate(&minPoint, maxPoint: &maxPoint, withNode: rodNode)
      }
    }
    for point in points {
      if point.type != nil {
        
        let pointNode = copyNode(point, toType: RotationPointNode.self)
        sprites.addChild(pointNode)
        
        calculate(&minPoint, maxPoint: &maxPoint, withNode: pointNode)
      }
    }
    
    for transfer in transfers {
      if transfer.name!.hasPrefix("transfer") {
        let transferNode = copyNode(transfer, toType: TransferNode.self)
        sprites.addChild(transferNode)
        calculate(&minPoint, maxPoint: &maxPoint, withNode: transferNode)
      }
    }
    
    let ballNode = copyNode(ball, toType: BallNode.self)
    sprites.addChild(ballNode)
    
    let destinationNode = copyNode(destination, toType: DestinationNode.self)
    sprites.addChild(destinationNode)
    
    calculate(&minPoint, maxPoint: &maxPoint, withNode: ballNode)
    calculate(&minPoint, maxPoint: &maxPoint, withNode: destinationNode)

    let centerPosition = (minPoint + maxPoint)/2
    
    let vector = CGPoint(x: scene!.size.width/2, y: scene!.size.height/2) - centerPosition
    for node in sprites.children {
      node.position += vector
    }
    scene?.sceneType = .testPlay
    scene?.editPlayScene = scene?.copy() as? LevelEditPlayScene
    scene?.editPlayScene?.sceneType = scene?.sceneType
    return scene
  }
  
  class func editSceneFromNodesData(nodesData: [Dictionary<String, String>], sceneType: LevelEditPlaySceneType) -> LevelEditPlayScene? {
    let scene = LevelEditPlayScene(fileNamed: "LevelEmpty")
    guard let sprites = scene?.childNodeWithName("Sprites") else {
      fatalError("The LevelEditPlayScene must have a node named Sprites")
    }
    
    for nodeData in nodesData {
      let nodeType = NodeType(rawValue: nodeData["type"]!)!
      var textureImageName = nodeType.rawValue
      if nodeType == .pointNode {
        textureImageName = PointNodeType(nodeName: nodeData["name"]).textureImageName()
      }
      if nodeType == .rod {
        textureImageName = "rod0"
      }
      let TypeClass = NodeType(rawValue: nodeData["type"]!)!.nodeType()
      let node = TypeClass.init(imageNamed: textureImageName)
      node.name = nodeData["name"]
      node.zRotation = CGFloat(Double(nodeData["zRotation"]!)!)
      node.position = CGPointFromString(nodeData["position"]!)
      sprites.addChild(node)
    }
    scene?.sceneType = sceneType
    scene?.editPlayScene = scene?.copy() as? LevelEditPlayScene
    scene?.editPlayScene?.sceneType = sceneType
    return scene
    
  }
  
  func shareLevel(levelName: String?) {
    var levelName = levelName
    if levelName == nil { levelName = "DIY" }
    HUD.show(.Progress)
    let task = Client.sharedInstance.shareLevel(self.editPlayScene!.spritesNode.children, levelName: levelName) { levelid in
      let shareURLString = "https://rodot.me/level/" + "\(levelid)"
      let shareURL = NSURL(string: shareURLString)!
      let str = "This is the game I made by RoDot try this!"
      let activityViewController = UIActivityViewController(activityItems: [str, shareURL], applicationActivities: nil)
      activityViewController.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeOpenInIBooks]
      activityViewController.completionWithItemsHandler = { _, isCompleted, _, _ in
        if isCompleted {
          GameKitHelper.shareInstance.reportAchievements(AchievementsHelper.shareAchievements())
          switch self.sceneType! {
          case .testPlay:
            SceneManager.sharedInstance.saveLevelData(self.editPlayScene!.spritesNode.children, levelName: levelName)
          default:
            break
          }
          self.backButtonTouchUpInsideActon()
        }
      }
      dispatch_async(dispatch_get_main_queue()) {
        
        HUD.hide()
        SceneManager.sharedInstance.presentingController.navigationController?.presentViewController(activityViewController, animated: true, completion: nil)
      }
    }//End for task completionHandler
    Client.sharedInstance.setTimeOutDuration(15, taskToCancel: task)
  }
  
  // MARK: Scene Life Cycle
  
  override func didMoveToView(view: SKView) {
    super.didMoveToView(view)
    addSmallShareButton()
    guard let editNode = scene?.childNodeWithName("Overlay")?.childNodeWithName("editButton") as? SKSpriteNode else {
      return
    }
    let editButton = copyNode(editNode, toButtonType: SKButtonNode.self, selectedTextue: nil, disabledTextue: nil)
    editNode.removeFromParent()
    editButton.actionTouchUpInside = {
      SKTAudio.sharedInstance().playSoundEffect("button_click_3.wav")
      self.view!.presentScene(self.editScene)
    }
    overlayNode.addChild(editButton)
  }
  
  override func newGame() {
    guard let editPlayScene = editPlayScene else {
      fatalError("The LevelEditPlayScene must have a editScene")
    }
    let newScene = editPlayScene
    newScene.editPlayScene = newScene.copy() as? LevelEditPlayScene
    newScene.editPlayScene?.sceneType = self.sceneType
    newScene.editScene = self.editScene
    newScene.scaleMode = self.scaleMode
    view?.presentScene(newScene)
  }
  
  override func win() {
//    super.win()
    playable = false
    
    SKTAudio.sharedInstance().playSoundEffect("success.wav")
    
    for entity in entities {
      if let entity = entity as? Rod {
        afterDelay(NSTimeInterval(0), runBlock: {
          let node = entity.componentForClass(RenderComponent.self)!.node
          let action = SKAction.scaleTo(0, duration: 0.5)
          action.timingMode = SKActionTimingMode.EaseInEaseOut
          node.runAction(action)
        })
      }
      if let entity = entity as? BasePointEntity {
        entity.componentForClass(RenderComponent.self)!.node.runAction(SKAction.scaleTo(0.01, duration: 0.8))
      }
      if let entity = entity as? Transfer {
        entity.componentForClass(RenderComponent.self)!.node.runAction(SKAction.scaleTo(0, duration: 0.8))
      }
    }
    afterDelay(1) { [unowned self] in
      self.overlayNode.addChild(self.restartButton)
      guard let sceneType = self.sceneType else { return }
      switch sceneType {
      case .selfPlay:
        self.overlayNode.addChild(self.shareButton)
        break
      case .testPlay:
        self.overlayNode.addChild(self.saveButton)
        self.overlayNode.addChild(self.shareButton)
      case .sharePlay:
        self.overlayNode.addChild(self.likeButton)
      }
    }
  }
  
  func addSmallShareButton() {
    guard let sceneType = sceneType else { return }
    switch sceneType {
    case .selfPlay:
      let smallShreButton = SKButtonNode(imageNameNormal: "sharebutton_s", selected: nil)
      smallShreButton.position = CGPoint(x: 1536-300-120-120, y: 1950)
      smallShreButton.name = "share_s"
      smallShreButton.zPosition = overlayNode.zPosition
      overlayNode.addChild(smallShreButton)
      smallShreButton.actionTouchUpInside = self.shareButton.actionTouchUpInside
      smallShreButton.alpha = 0
      smallShreButton.runAction(SKAction.fadeInWithDuration(0.66))
    default:
      return
    }
  }
  
  override func addRecordButton() {
    guard let sceneType = sceneType else { return }
    switch sceneType {
    case .testPlay:
      return
    default:
      super.addRecordButton()
    }
  }
  
  func showEnterLevelNameAlert(actionName:String ,completionHandler:(String?)->()) {
    let alertController = UIAlertController(title: "Level Name", message: "Plese enter the level name.", preferredStyle: .Alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { _ in }
    let saveAction = UIAlertAction(title: actionName, style: .Default) { action in
      let levelNameTextField = alertController.textFields![0] as UITextField
      completionHandler(levelNameTextField.text)
//      SceneManager.sharedInstance.saveLevelData(self.editPlayScene!.spritesNode.children, levelName: loginTextField.text)
//      HUD.flash(.Success, delay: 1.3) { isFinished in
//        SceneManager.sharedInstance.backToStartScene()
//      }
      
    }
    saveAction.enabled = false
    alertController.addAction(cancelAction)
    alertController.addAction(saveAction)
    
    alertController.addTextFieldWithConfigurationHandler { textField in
      textField.placeholder = "Name"
      NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) {
        nofitication in
        saveAction.enabled = textField.text != nil
      }
      
    }
    SceneManager.sharedInstance.presentingController.presentViewController(alertController, animated: true, completion: nil)

  }
  
}


// MARK: Help Functions

private func copyNode(node:SKSpriteNode, toType Type: SKSpriteNode.Type) -> SKSpriteNode {
  let copyNode = Type.init(texture: node.texture)
  copyNode.size = node.size
  copyNode.position = node.position
  copyNode.name = node.name
  copyNode.zRotation = node.zRotation
  return copyNode
}

private func calculate(inout minPoint: CGPoint, inout maxPoint: CGPoint, withNode node: SKSpriteNode) {
  minPoint.x = min(minPoint.x, node.position.x)
  minPoint.y = min(minPoint.y, node.position.y)
  maxPoint.x = max(maxPoint.x, node.position.x)
  maxPoint.y = max(maxPoint.y, node.position.y)
}