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

let LikedLevelIdsKey = "LikedLevelIds"
let SharedLevlsDicKey = "SharedLevlsDic"

enum LevelEditPlaySceneType {
  case testPlay    // For when DIYing
  case selfPlay(String?, levelObjectId: String)     // For when playing self designed level, String is the level Name
  case sharePlay(Int)    // For when playing others sharing level, Int is levelid
  
  
}

class LevelEditPlayScene: LevelScene {
  
  // MARK: Properties
  var editPlayScene: LevelEditPlayScene?
  var editScene: LevelEditorScene?
  
  var sceneType: LevelEditPlaySceneType?
  
  var getLevelPlaySessionTask: URLSessionTask?
  
  lazy var restartButton: SKButtonNode = {
    let restartButton = SKButtonNode(imageNameNormal: "restartbutton", selected: nil)
    restartButton.name = "restartbutton"
    restartButton.zPosition = self.overlayNode.zPosition
    restartButton.actionTouchUpInside =  {
      SKTAudio.sharedInstance().playSoundEffect("restart_click.wav")
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
      SKTAudio.sharedInstance().playSoundEffect("menu_click.wav")
      switch self.sceneType! {
      case .selfPlay(let levelName, let objectId):
        if let levelid = self.checkLevelIsAlreadyShared(objectId) {
          self.shareLevelDirectory(levelName!, levelid: levelid)
        }else {
          self.shareLevel(levelName)
        }
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
      SKTAudio.sharedInstance().playSoundEffect("menu_click.wav")
      self.showEnterLevelNameAlert("Save") { levelName in
        SceneManager.sharedInstance.saveLevelData(self.editPlayScene!.spritesNode.children, levelName: levelName)
        HUD.flash(.success, delay: 1.3) { isFinished in
          SceneManager.sharedInstance.backToStartScene()
        }
      }
      
    }
    return saveButton
  }()
  
  lazy var likeButton: SKButtonNode = {
    let likeButton = SKButtonNode(imageNameNormal: "likebutton", selected: "likebutton_selected", disabled: "likebutton_selected")
    likeButton.name = "likebutton"
    likeButton.zPosition = self.overlayNode.zPosition
    likeButton.actionTouchUpInside = { [unowned self] in
      guard let sceneType = self.sceneType else { return }
      switch sceneType {
      case .sharePlay(let levelId):
        likeButton.isEnabled = false
        self.animationLikeIcon()
        SKTAudio.sharedInstance().playSoundEffect("menu_click.wav")
        
        Client.sharedInstance.likeLevel(levelId) {
          print("like")
        }
        if var likedLevelIds = UserDefaults.standard.array(forKey: LikedLevelIdsKey) as? [Int] {
          likedLevelIds.append(levelId)
          UserDefaults.standard.set(likedLevelIds, forKey: LikedLevelIdsKey)
        }
      default:
        break
      }
    }
    likeButton.position = CGPoint(x: self.size.width/2, y: 1200)
    return likeButton
  }()
  
  // MARK: Class Methods
  class func editScene(_ rods: [SKSpriteNode], points: [PointButton], ball: SKSpriteNode, destination: SKSpriteNode, transfers: [SKSpriteNode]) -> LevelEditPlayScene? {
    let scene = LevelEditPlayScene(fileNamed: "LevelEdirorScene")
    
    guard let sprites = scene?.childNode(withName: "Sprites") else {
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
  
  class func editSceneFromNodesData(_ nodesData: [Dictionary<String, String>], sceneType: LevelEditPlaySceneType) -> LevelEditPlayScene? {
    let scene = LevelEditPlayScene(fileNamed: "LevelEmpty")
    guard let sprites = scene?.childNode(withName: "Sprites") else {
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
  
  func shareLevel(_ levelName: String?) {
    var levelName = levelName
    if levelName == nil { levelName = "DIY" }
    HUD.show(.progress)
    let task = Client.sharedInstance.shareLevel(self.editPlayScene!.spritesNode.children, levelName: levelName) { levelid in
//      let shareURLString = "https://rodot.me/level/" + "\(levelid)"
//      let shareURL = NSURL(string: shareURLString)!
//      let str = "This is the level I made named:\(levelName!) by RoDot try this!"
//      let activityViewController = UIActivityViewController(activityItems: [str, shareURL], applicationActivities: nil)
//      activityViewController.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeOpenInIBooks]
//      activityViewController.completionWithItemsHandler = { _, isCompleted, _, _ in
//        if isCompleted {
//          GameKitHelper.shareInstance.reportAchievements(AchievementsHelper.shareAchievements())
//          LeaderboardHelper.reportMostShareTimesLeaderboard()
//          switch self.sceneType! {
//          case .testPlay:
//            SceneManager.sharedInstance.saveLevelData(self.editPlayScene!.spritesNode.children, levelName: levelName)
//          default:
//            break
//          }
//          self.backButtonTouchUpInsideActon()
//        }
//      }
      //      dispatch_async(dispatch_get_main_queue()) {
      //
      //        HUD.hide()
      //        SceneManager.sharedInstance.presentingController.navigationController?.presentViewController(activityViewController, animated: true, completion: nil)
      //      }
      self.shareLevelDirectory(levelName!, levelid: levelid)
    }//End for task completionHandler
    Client.sharedInstance.setTimeOutDuration(15, taskToCancel: task)
  }
  
  func shareLevelDirectory(_ levelName: String, levelid: Int) {
    let shareURLString = "https://rodot.me/level/" + "\(levelid)"
    let shareURL = URL(string: shareURLString)!
    let str = "This is the level I made named:\(levelName) by RoDot try this!"
    let activityViewController = UIActivityViewController(activityItems: [str, shareURL], applicationActivities: nil)
    activityViewController.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.openInIBooks]
    activityViewController.completionWithItemsHandler = { _, isCompleted, _, _ in
      if isCompleted {
        GameKitHelper.shareInstance.reportAchievements(AchievementsHelper.shareAchievements())
        LeaderboardHelper.reportMostShareTimesLeaderboard()
        switch self.sceneType! {
        case .testPlay:
          
          //MARK: TODO ....
          let objectidStr = SceneManager.sharedInstance.saveLevelData(self.editPlayScene!.spritesNode.children, levelName: levelName)
          self.saveObjectIdLevlIdToNSUserDefalut(objectidStr, levelId: levelid)
        case .selfPlay(_ , levelObjectId: let objectidStr):
          self.saveObjectIdLevlIdToNSUserDefalut(objectidStr, levelId: levelid)
        default:
          break
        }
        self.backButtonTouchUpInsideActon()
      }
    }
    DispatchQueue.main.async {
      
      HUD.hide()
      SceneManager.sharedInstance.presentingController.navigationController?.present(activityViewController, animated: true, completion: nil)
    }
  }
  
  func checkLevelIsAlreadyShared(_ objectId: String) -> Int? {
    guard let dic = UserDefaults.standard.dictionary(forKey: SharedLevlsDicKey) as? [String: Int] else { return nil }
    if let levelid = dic[objectId] {
      return levelid
    }else {
      return nil
    }
  }
  
  func saveObjectIdLevlIdToNSUserDefalut(_ objectidStr: String, levelId: Int) {
    guard var dic = UserDefaults.standard.dictionary(forKey: SharedLevlsDicKey) as? [String: Int] else { return }
    dic[objectidStr] = levelId
    UserDefaults.standard.set(dic, forKey: SharedLevlsDicKey)
  }
  
  
  
  // MARK: Scene Life Cycle
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    addSmallShareButton()
    
    addTopLevelDetilsLabels()
    
    guard let editNode = scene?.childNode(withName: "Overlay")?.childNode(withName: "editButton") as? SKSpriteNode else {
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
    getLevelPlaySessionTask?.cancel()
    let newScene = editPlayScene
    newScene.editPlayScene = newScene.copy() as? LevelEditPlayScene
    newScene.editPlayScene?.sceneType = self.sceneType
    newScene.editScene = self.editScene
    newScene.scaleMode = self.scaleMode
    view?.presentScene(newScene)
  }
  
  func animationWinOrLoseTiemsLabel(_ isWin: Bool) {
    let label = isWin ? overlayNode.childNode(withName: "win") : overlayNode.childNode(withName: "lose")
    guard let titleLabel = label as? SKLabelNode else { return }
    guard let timesLabel = titleLabel.childNode(withName: "label") as? SKLabelNode else { return }
    let dx: CGFloat = 20
    let moveUpAction = SKAction.moveBy(x: dx, y: 0, duration: 0.33)
    let fadeOutAction = SKAction.fadeOut(withDuration: 0.33)
    let groupAction0 = SKAction.group([moveUpAction, fadeOutAction])
    let runblock = SKAction.run {
      if let times = Int(timesLabel.text!) {
        timesLabel.text = (times+1).stringify()
      }
      timesLabel.position.x = timesLabel.position.x - 2*dx
    }
    let fadeInAction = SKAction.fadeIn(withDuration: 0.33)
    let groupAction1 = SKAction.group([moveUpAction, fadeInAction])
    timesLabel.run(SKAction.sequence([groupAction0, runblock, groupAction1]))
    
  }
  
  override func win() {
//    super.win()
    playable = false
    
    SKTAudio.sharedInstance().playSoundEffect("success.wav")
    
    if let sceneType = sceneType {
      switch sceneType {
      case .sharePlay(let levelId):
        Client.sharedInstance.levelWin(levelId) { }
        animationWinOrLoseTiemsLabel(true)
      default:
        break
      }
    }
    
    for entity in entities {
      if let entity = entity as? Rod {
        afterDelay(TimeInterval(0), runBlock: {
          let node = entity.component(ofType: RenderComponent.self)!.node
          let action = SKAction.scale(to: 0, duration: 0.5)
          action.timingMode = SKActionTimingMode.easeInEaseOut
          node.run(action)
        })
      }
      if let entity = entity as? BasePointEntity {
        entity.component(ofType: RenderComponent.self)!.node.run(SKAction.scale(to: 0.01, duration: 0.8))
      }
      if let entity = entity as? Transfer {
        entity.component(ofType: RenderComponent.self)!.node.run(SKAction.scale(to: 0, duration: 0.8))
      }
    }
    afterDelay(1) { [unowned self] in
      self.overlayNode.addChild(self.restartButton)
      (self.overlayNode.childNode(withName: "restart") as? SKButtonNode)?.isEnabled = true
      self.playable = true
      guard let sceneType = self.sceneType else { return }
      switch sceneType {
      case .selfPlay:
        self.overlayNode.addChild(self.shareButton)
        break
      case .testPlay:
        self.overlayNode.addChild(self.saveButton)
        self.overlayNode.addChild(self.shareButton)
      case .sharePlay(let levelId):
        self.overlayNode.addChild(self.likeButton)
        self.likeButton.isEnabled = !self.checkIsLikeLevel(levelId)
      }
    }
  }
  
  override func lose() {
    super.lose()
    if let sceneType = sceneType {
      switch sceneType {
      case .sharePlay(let levelId):
        Client.sharedInstance.levelLose(levelId) { }
        animationWinOrLoseTiemsLabel(false)
      default:
        break
      }
    }
  }
  
  func addSmallShareButton() {
    guard let sceneType = sceneType else { return }
    switch sceneType {
    case .selfPlay:
      let smallShreButton = SKButtonNode(imageNameNormal: "sharebutton_s", selected: nil)
      let margin: CGFloat = screenRecordingAvailable ? (120+120) : 120
      smallShreButton.position = CGPoint(x: size.width-xMargin-108-margin, y: 1950)
      smallShreButton.name = "share_s"
      smallShreButton.zPosition = overlayNode.zPosition
      overlayNode.addChild(smallShreButton)
      smallShreButton.actionTouchUpInside = self.shareButton.actionTouchUpInside
      smallShreButton.alpha = 0
      smallShreButton.run(SKAction.fadeIn(withDuration: 0.66))
    default:
      return
    }
  }
  
  func addTopLevelDetilsLabels() {
    guard let sceneType = sceneType else { return }
    switch sceneType {
    case .sharePlay(let levelid):
      loadTopPlayInfo(levelid)
//      Client.sharedInstance.getLvelLikeCount(levelid) { likeCount in
//        let likeIcon = SKSpriteNode(imageNamed: "likescount")
//        let margin: CGFloat = 120 + 120
//        likeIcon.position = CGPoint(x: self.size.width-self.xMargin-108-margin, y: 1950)
//        likeIcon.name = "likeIcon"
//        likeIcon.zPosition = self.overlayNode.zPosition
//        self.overlayNode.addChild(likeIcon)
//        let label = SKLabelNode(text: likeCount.stringify())
//        label.position = CGPoint(x: -likeIcon.size.width/2-15, y: 0)
//        label.verticalAlignmentMode = .Center
//        label.horizontalAlignmentMode = .Right
//        label.zPosition = likeIcon.zPosition + 10
//        label.fontName = "ArialRoundedMTBold"
////        print(label.colorBlendFactor)
////        label.colorBlendFactor = 1
//        label.fontColor = UIColor(red: 255/255.0, green: 91/255.0, blue: 91/255.0, alpha: 1)
//        label.fontSize = likeIcon.size.width / 1.1
//        label.name = "label"
//        likeIcon.addChild(label)
//        likeIcon.alpha = 0
//        dispatch_async(dispatch_get_main_queue()) {
//          likeIcon.runAction(SKAction.fadeInWithDuration(0.66))
//        }
//      }
//      
//      loadLoseAndWinLabels(levelid)
      
      
    default:
      break
    }
  }
  
  func loadTopPlayInfo(_ levelid: Int) {
    getLevelPlaySessionTask = Client.sharedInstance.getPlayLevelInfo(levelid) { playInfo in
      guard let likeCount = playInfo[Client.JSONBodyKeys.LevelLikesCount], let winTimes = playInfo[Client.JSONBodyKeys.LevelWinTimes], let loseTimes = playInfo[Client.JSONBodyKeys.LevelLoseTimes] else { return }
      
      let likeIcon = SKSpriteNode(imageNamed: "likescount")
      let margin: CGFloat = 120 + 120
      likeIcon.position = CGPoint(x: self.size.width-self.xMargin-108-margin, y: 1950)
      likeIcon.name = "likeIcon"
      likeIcon.zPosition = self.overlayNode.zPosition
      self.overlayNode.addChild(likeIcon)
      let label = SKLabelNode(text: likeCount.stringify())
      label.position = CGPoint(x: -likeIcon.size.width/2-15, y: 0)
      label.verticalAlignmentMode = .center
      label.horizontalAlignmentMode = .right
      label.zPosition = likeIcon.zPosition + 10
      label.fontName = "ArialRoundedMTBold"
      //        print(label.colorBlendFactor)
      //        label.colorBlendFactor = 1
      label.fontColor = UIColor(red: 255/255.0, green: 91/255.0, blue: 91/255.0, alpha: 1)
      label.fontSize = likeIcon.size.width / 1.1
      label.name = "label"
      likeIcon.addChild(label)
      likeIcon.alpha = 0
      
      //Winlabels
      let winColor = UIColor(red: 100/255.0, green: 221/255.0, blue: 23/255.0, alpha: 1)
      let winLabel = self.setUpWinOrLostLabel("Win:", fontColor: winColor, labelName: "win", position: CGPoint(x: self.xMargin + 108 + 90, y: 1980))
      self.overlayNode.addChild(winLabel)
      
      let winTimesLabel = self.setUpWinOrLostLabel(winTimes.stringify(), fontColor: winColor, labelName: "label", position: CGPoint(x: 170, y: 0))
      winTimesLabel.zPosition -= 10
      winLabel.addChild(winTimesLabel)
      winLabel.alpha = 0
      
      //LoseLabels
      let loseColor = UIColor(red: 224/255.0, green: 0/255.0, blue: 100/255.0, alpha: 1)
      let loseLabel = self.setUpWinOrLostLabel("Lose:", fontColor: loseColor, labelName: "lose", position: CGPoint(x: self.xMargin + 108 + 90, y: 1920))
      self.overlayNode.addChild(loseLabel)
      
      let loseimesLabel = self.setUpWinOrLostLabel(loseTimes.stringify(), fontColor: loseColor, labelName: "label", position: CGPoint(x: 170, y: 0))
      loseimesLabel.zPosition -= 10
      loseLabel.addChild(loseimesLabel)
      loseLabel.alpha = 0
      DispatchQueue.main.async {
        likeIcon.run(SKAction.fadeIn(withDuration: 0.66))
        winLabel.run(SKAction.fadeIn(withDuration: 0.66))
        loseLabel.run(SKAction.fadeIn(withDuration: 0.55))
      }
      self.getLevelPlaySessionTask = nil
    }
  }
  
  func loadLoseAndWinLabels(_ levelid: Int) {
    Client.sharedInstance.getLevelWinTimes(levelid) { times in
      let winColor = UIColor(red: 100/255.0, green: 221/255.0, blue: 23/255.0, alpha: 1)
      let winLabel = self.setUpWinOrLostLabel("Win:", fontColor: winColor, labelName: "win", position: CGPoint(x: self.xMargin + 108 + 90, y: 1980))
      self.overlayNode.addChild(winLabel)
      
      let winTimesLabel = self.setUpWinOrLostLabel(times.stringify(), fontColor: winColor, labelName: "label", position: CGPoint(x: 170, y: 0))
      winTimesLabel.zPosition -= 10
      winLabel.addChild(winTimesLabel)
      winLabel.alpha = 0
      DispatchQueue.main.async {
        winLabel.run(SKAction.fadeIn(withDuration: 0.55))
      }
    }
    
    Client.sharedInstance.getLevelLoseTimes(levelid) { times in
      let loseColor = UIColor(red: 224/255.0, green: 0/255.0, blue: 100/255.0, alpha: 1)
      let loseLabel = self.setUpWinOrLostLabel("Lose:", fontColor: loseColor, labelName: "lose", position: CGPoint(x: self.xMargin + 108 + 90, y: 1920))
      self.overlayNode.addChild(loseLabel)
      
      let loseimesLabel = self.setUpWinOrLostLabel(times.stringify(), fontColor: loseColor, labelName: "label", position: CGPoint(x: 170, y: 0))
      loseimesLabel.zPosition -= 10
      loseLabel.addChild(loseimesLabel)
      loseLabel.alpha = 0
      DispatchQueue.main.async {
        loseLabel.run(SKAction.fadeIn(withDuration: 0.55))
      }
    }
  }
  
  func setUpWinOrLostLabel(_ text: String, fontColor: UIColor, labelName: String, position: CGPoint) -> SKLabelNode {
    let fontSize: CGFloat = 60
    let fontName = "ArialRoundedMTBold"
    
    let label = SKLabelNode(text: text)
    label.position = position
    label.zPosition = self.overlayNode.zPosition
    label.fontColor = fontColor
    label.fontSize = fontSize
    label.horizontalAlignmentMode = .left
    label.verticalAlignmentMode = .center
    label.fontName = fontName
    label.name = labelName
    
    return label
  }
  
  func animationLikeIcon() {
    guard let label = overlayNode.childNode(withName: "likeIcon")?.childNode(withName: "label") as? SKLabelNode else { return }
    let dy: CGFloat = 20
    let moveUpAction = SKAction.moveBy(x: 0, y: dy, duration: 0.33)
    let fadeOutAction = SKAction.fadeOut(withDuration: 0.33)
    let groupAction0 = SKAction.group([moveUpAction, fadeOutAction])
    let runblock = SKAction.run {
      if let likesCount = Int(label.text!) {
        label.text = (likesCount+1).stringify()
      }
      label.position.y = -dy
    }
    let fadeInAction = SKAction.fadeIn(withDuration: 0.33)
    let groupAction1 = SKAction.group([moveUpAction, fadeInAction])
    label.run(SKAction.sequence([groupAction0, runblock, groupAction1]))
    
  }
  
  func checkIsLikeLevel(_ levelId: Int) -> Bool {
    guard let likedLevelIds = UserDefaults.standard.object(forKey: LikedLevelIdsKey) as? [Int]
      else { return  false }
    if likedLevelIds.contains(levelId) {
      return true
    }else {
      return false
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
  
  func showEnterLevelNameAlert(_ actionName:String ,completionHandler:@escaping (String?)->()) {
    let alertController = UIAlertController(title: "Level Name", message: "Plese enter the level name.", preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
    let saveAction = UIAlertAction(title: actionName, style: .default) { action in
      let levelNameTextField = alertController.textFields![0] as UITextField
      completionHandler(levelNameTextField.text)
//      SceneManager.sharedInstance.saveLevelData(self.editPlayScene!.spritesNode.children, levelName: loginTextField.text)
//      HUD.flash(.Success, delay: 1.3) { isFinished in
//        SceneManager.sharedInstance.backToStartScene()
//      }
      
    }
    saveAction.isEnabled = false
    alertController.addAction(cancelAction)
    alertController.addAction(saveAction)
    
    alertController.addTextField { textField in
      textField.placeholder = "Name"
      NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) {
        nofitication in
        saveAction.isEnabled = textField.text != nil
      }
      
    }
    SceneManager.sharedInstance.presentingController.present(alertController, animated: true, completion: nil)

  }
  
}


// MARK: Help Functions

private func copyNode(_ node:SKSpriteNode, toType Type: SKSpriteNode.Type) -> SKSpriteNode {
  let copyNode = Type.init(texture: node.texture)
  copyNode.size = node.size
  copyNode.position = node.position
  copyNode.name = node.name
  copyNode.zRotation = node.zRotation
  return copyNode
}

private func calculate(_ minPoint: inout CGPoint, maxPoint: inout CGPoint, withNode node: SKSpriteNode) {
  minPoint.x = min(minPoint.x, node.position.x)
  minPoint.y = min(minPoint.y, node.position.y)
  maxPoint.x = max(maxPoint.x, node.position.x)
  maxPoint.y = max(maxPoint.y, node.position.y)
}
