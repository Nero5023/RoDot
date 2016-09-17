//
//  StartScene.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/23.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol StartSceneDelegate: class {
  func didSelectMyDiysButton(_ scene: StartScene)
  func didSelectMoreButton(_ scene: StartScene, buttonCenterPosition: CGPoint)
}

let IsFirstLanchedKey = "FirstLanched"

class StartScene: SKScene, SceneLayerProtocol {
  
  // MARK: Properties
  
  let TotalBallNodesCount: Int = 9
  
  var staticBallCount: Int = 0

  
  var titlePositoin: CGPoint!
  
  var didTouchedScreen = false
  var touchable = false
  var maxSizeBallNode: StartBallNode!
  var ballNodes = [StartBallNode]()
  
  var isFirstTime: Bool = true
  
  weak var startSceneDelegate: StartSceneDelegate?
  
  var themeButtons = [SKButtonNode]()
  
  var levelSelectButtons = [SKButtonNode]()
  
  var fromThemeType: ThemeType?
  
  // MARK: Scene Life Cycle
  
  override func didMove(to view: SKView) {
    
    guard isFirstTime else {
      updateSelectButtonsState()
      fromDiySceneAnimation()
      return
    }
    isFirstTime = false
    
    let titleLabelNode = childNode(withName: "title")!
    titlePositoin = titleLabelNode.position
    titleLabelNode.alpha = 0
    titleLabelNode.run(SKAction.fadeAlpha(to: 1, duration: 1.5))
    
    setUpRodAndBall()
  }
  
  
  func setUpRodAndBall() {
    physicsWorld.contactDelegate = self
    enumerateChildNodes(withName: "//ball", using: { node, _ in
      let node = node as! StartBallNode
      node.originalPosition = node.position
      node.zPosition = self.overlayNode.zPosition + 10
      node.position.y = CGFloat.random(min: -300, max: -50)
      let moveUpaction = SKAction.move(to: node.originalPosition , duration: TimeInterval(CGFloat.random(min: 0.8, max: 1.2)))
      moveUpaction.timingMode = SKActionTimingMode.easeOut
      let waitAction = SKAction.wait(forDuration: TimeInterval(CGFloat.random(min: 0, max: 0.33)))
      let addPhysicsAction = SKAction.run({
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width/2)
        node.physicsBody!.allowsRotation = false
        node.physicsBody!.friction = 0
        node.physicsBody!.restitution = 1
        node.physicsBody!.linearDamping = 0.08
        node.physicsBody!.categoryBitMask = PhysicsCategory.Ball
        node.physicsBody!.collisionBitMask = PhysicsCategory.Rod
        node.physicsBody!.contactTestBitMask = PhysicsCategory.Rod
        if self.touchable == false { self.touchable = true }
      })
      let actionSequence = SKAction.sequence([waitAction, moveUpaction, addPhysicsAction])
      node.run(actionSequence)
      if self.maxSizeBallNode == nil {
        self.maxSizeBallNode = node
      }else {
        self.maxSizeBallNode = self.maxSizeBallNode.size.width > node.size.width ? self.maxSizeBallNode : node
      }
      self.ballNodes.append(node)
    })
//    SKTAudio.sharedInstance().playBackgroundMusic("background_1.wav")
    enumerateChildNodes(withName: "//rod", using: { node, _ in
      let node = node as! SKSpriteNode
      node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
      node.physicsBody!.affectedByGravity = false
      node.physicsBody!.isDynamic = false
      node.physicsBody!.friction = 0
      node.physicsBody!.categoryBitMask = PhysicsCategory.Rod
      node.physicsBody!.collisionBitMask = PhysicsCategory.Ball
      node.physicsBody!.contactTestBitMask = PhysicsCategory.Ball
      node.alpha = 0
    })
    
    
    guard UserDefaults.standard.bool(forKey: IsFirstLanchedKey) else { return }
    UserDefaults.standard.set(false, forKey: IsFirstLanchedKey)
    let tapInstruction = SKSpriteNode(imageNamed: "tap")
    tapInstruction.name = "tap"
    tapInstruction.zPosition = hudNode.zPosition
    tapInstruction.position = CGPoint(x: 1100, y: 300)
    hudNode.addChild(tapInstruction)
    tapInstruction.alpha = 0
    let fadeInAction = SKAction.fadeIn(withDuration: 0.8)
    let fadeOutActoin = SKAction.fadeOut(withDuration: 1.3)
    fadeInAction.timingMode = .easeInEaseOut
    fadeOutActoin.timingMode = .easeInEaseOut
    let tapAction = SKAction.sequence([fadeInAction, fadeOutActoin, SKAction.wait(forDuration: 0.1)])
    tapInstruction.run(SKAction.sequence([
      SKAction.wait(forDuration: 2), SKAction.repeatForever(tapAction)
      ]))
  }
  
  // Update
  override func update(_ currentTime: TimeInterval) {
    if isPaused { return }
    enumerateChildNodes(withName: "//ball", using: { node, _ in
      let node = node as! StartBallNode
      if self.didTouchedScreen {
        if let lastVelocity = node.lastVelocity {
          if lastVelocity.dy <= 0 && node.physicsBody?.velocity.dy > 0{
            let xAction = SKAction.moveTo(x: self.titlePositoin.x, duration: 0.8)
            let maxY = max(node.originalPosition.y, self.titlePositoin.y)
            let yAction0 = SKAction.moveTo(y: CGFloat.random(min: maxY+10, max: maxY+50), duration: 0.4)
            let yAction1 = SKAction.moveTo(y: self.titlePositoin.y, duration: 0.4)
            yAction0.timingMode = SKActionTimingMode.easeOut
            yAction1.timingMode = SKActionTimingMode.easeIn
            let addSaticBallCountAction = SKAction.run({
              self.staticBallCount+=1
            })
            node.physicsBody = nil
            let groupAction = SKAction.group([xAction, SKAction.sequence([yAction0, yAction1, addSaticBallCountAction])])
            
            node.run(groupAction)
            
          }
        }
      }
      
      node.lastVelocity = node.physicsBody?.velocity
    })
    
    if staticBallCount > 0 && childNode(withName: "title")?.action(forKey: "fadeout") == nil{
      let fadeoutAction = SKAction.fadeOut(withDuration: 0.5)
      let removeAction = SKAction.run({
        self.childNode(withName: "title")?.removeFromParent()
      })
      childNode(withName: "title")?.run(SKAction.sequence([fadeoutAction, removeAction]), withKey: "fadeout")
    }
    
    if staticBallCount == TotalBallNodesCount {
      staticBallCount = 0
      for node in ballNodes {
        if node != maxSizeBallNode {
          node.removeFromParent()
        }
      }
      let scaleAction0 = SKAction.resize(toWidth: 20, height: 20, duration: 0.3)
      scaleAction0.timingMode = SKActionTimingMode.easeOut
      let scaleToWidth = sqrt(playableRect.width/2*playableRect.width/2+maxSizeBallNode.position.y*maxSizeBallNode.position.y)*2 + 200
      let scaleAction1 = SKAction.resize(toWidth: scaleToWidth, height: scaleToWidth, duration: 0.5)
      scaleAction1.timingMode = SKActionTimingMode.easeIn
      let runBlock = SKAction.run {
        self.addThemeButtons()
        self.addBackground()
//        self.maxSizeBallNode.removeFromParent()
      }
      let runBlock1 = SKAction.run {
        SKTAudio.sharedInstance().playBackgroundMusic("background_music.wav")
        if !SceneManager.sharedInstance.backgroundMusicEabled() {
          SKTAudio.sharedInstance().pauseBackgroundMusic()
        }
      }
      maxSizeBallNode.run(SKAction.sequence([scaleAction0, runBlock ,scaleAction1, runBlock1]))
    }
  }
  
  
  // MARK: Actions
  
  
  
  
  func addBackground() {
    let background = SKSpriteNode(texture: SKTexture(imageNamed: "background"))
    background.zPosition = bgNode.zPosition
    background.anchorPoint = CGPoint.zero
    background.position = playableRect.origin
//    background.size = playableRect.size
    background.size = backgroundRect.size
    background.position = backgroundRect.origin
//    if view!.bounds.size.height/view!.bounds.size.width <= 1.5 { // not 16:9
//      background.size = size
//      background.position = CGPoint.zero
//    }else {
//      background.size = playableRect.size
//      background.position = playableRect.origin
//    }
    
    background.alpha = 0
    bgNode.addChild(background)
    let runblock = SKAction.run{
      self.maxSizeBallNode.zPosition = self.bgNode.zPosition - 10
    }
    
    background.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), runblock, SKAction.fadeIn(withDuration: 0.5)]))
    maxSizeBallNode.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.fadeOut(withDuration: 0.33), SKAction.run{ self.maxSizeBallNode.removeFromParent() }]))
  }
  
  // theme button
  func addThemeButtons() {
    
    themeButtons.reserveCapacity(3)
    let theme1 = addThemeButton(themeType: .Theme1, position: CGPoint(x: 192 + 528 + 261, y: 1417 + 261))
    themeButtons.append(theme1)
    let theme2 = addThemeButton(themeType: .Theme2, position: CGPoint(x: 192 + 100 + 213, y: 1013 + 213))
    themeButtons.append(theme2)
    let theme3 = addThemeButton(themeType: .Theme3, position: CGPoint(x: 192 + 690 + 140, y: 779 + 140))
    themeButtons.append(theme3)
    
    let diyButton = SKButtonNode(imageNameNormal: "diy", selected: "diy_selected")
    diyButton.position = CGPoint(x: 192 + 227 + 210, y: 469 + 210)
    diyButton.zPosition = overlayNode.zPosition 
    overlayNode.addChild(diyButton)
    diyButton.actionTouchUpInside = { [unowned self] in
      SKTAudio.sharedInstance().playSoundEffect("diy_click.wav")
      let scaleAction = SKAction.scale(to: 0.2, duration: 0.33)
      let fadoutAction = SKAction.fadeOut(withDuration: 0.33)
      let scaleAndFadeOutAction = SKAction.group([scaleAction, fadoutAction])
      let runBlock = SKAction.run {
        let editScene = LevelEditorScene(fileNamed:"LevelEditor")
        editScene?.scaleMode = self.scaleMode
        self.view?.presentScene(editScene)
      }
      diyButton.run(SKAction.sequence([scaleAndFadeOutAction, runBlock]))
      for button in self.themeButtons where button != diyButton {
        button.run(SKAction.fadeOut(withDuration: 0.33))
      }
    }
    diyButton.alpha = 0
    diyButton.run(SKAction.sequence([SKAction.wait(forDuration: 0.9), SKAction.fadeIn(withDuration: 0.5)]))
    
    let myDiybutton = SKButtonNode(imageNameNormal: "mydiy", selected: "mydiy_selected")
    myDiybutton.position = CGPoint(x: 192 + 635 + 120, y: 178 + 120)
    myDiybutton.zPosition = overlayNode.zPosition
    overlayNode.addChild(myDiybutton)
    myDiybutton.actionTouchUpInside = { [unowned self] in
      self.startSceneDelegate?.didSelectMyDiysButton(self)
    }
    myDiybutton.alpha = 0
    myDiybutton.run(SKAction.sequence([SKAction.wait(forDuration: 0.9), SKAction.fadeIn(withDuration: 0.5)]))
    
    themeButtons.append(diyButton)
    themeButtons.append(myDiybutton)
    
    let moreButton = SKButtonNode(imageNameNormal: "more", selected: nil)
    let factor = self.size.height / view!.bounds.size.height
    moreButton.size = CGSize(width: FloatingButtonWidth * factor, height: FloatingButtonWidth * factor)
    moreButton.position = CGPoint(x: 1536 - xMargin - 37 - moreButton.size.width/2, y: 37 + moreButton.size.width/2)
    overlayNode.addChild(moreButton)
    moreButton.actionTouchUpInside = {
      SKTAudio.sharedInstance().playSoundEffect("fadeout.mp3")
      let moreButtonPosisitonInScene = self.convert(moreButton.position, from: moreButton.parent!)
      let centerPosition = self.view!.convert(moreButtonPosisitonInScene, from: self)
      self.startSceneDelegate?.didSelectMoreButton(self, buttonCenterPosition: centerPosition)
    }
    
    moreButton.alpha = 0
    moreButton.run(SKAction.sequence([SKAction.wait(forDuration: 0.9), SKAction.fadeIn(withDuration: 0.5)]))
    
  }
  
  
  func updateThemeButtonInfo(_ themeType: ThemeType) {
    let themeButton = overlayNode.childNode(withName: themeType.rawValue) as! SKButtonNode
    if themeButton.isEnabled {
      if let label = themeButton.childNode(withName: "label") as? SKLabelNode {
        let passedLevels = LevelManager.shareInstance.getUnlockLevels(themeType: themeType) - 1
        label.text = "\(passedLevels)/25"
      }
    }else {
      if LevelManager.shareInstance.themeEabled(themeType) {
        addLabelToThemeButton(themeButton, themeType: themeType)
        themeButton.isEnabled = true
      }
    }
  }
  
  func updateAllThemeButtonInfo() {
    ThemeType.allTypes.forEach {
      self.updateThemeButtonInfo($0)
    }
  }
  
  func addLabelToThemeButton(_ themeButton: SKButtonNode, themeType: ThemeType) {
    guard LevelManager.shareInstance.themeEabled(themeType) else { return }
    let passedLevels = LevelManager.shareInstance.getUnlockLevels(themeType: themeType) - 1
    let label = SKLabelNode(text: "\(passedLevels)/25")
    label.position = CGPoint(x: 0, y: 0)
    label.verticalAlignmentMode = .center
    label.zPosition = 10
    label.fontName = "ArialRoundedMTBold"
    label.color = UIColor.white
    label.fontSize = themeButton.size.width/3.5
    label.name = "label"
    themeButton.addChild(label)
  }
  
  //Help Method
  func addThemeButton(themeType: ThemeType, position: CGPoint) -> SKButtonNode {
    let theme = SKButtonNode(imageNameNormal: themeType.rawValue, selected: themeType.rawValue+"_selected", disabled: themeType.rawValue + "_disabled")
    theme.position = position
    theme.zPosition = overlayNode.zPosition
    theme.name = themeType.rawValue
    overlayNode.addChild(theme)
    if LevelManager.shareInstance.themeEabled(themeType) {
//      let passedLevels = LevelManager.shareInstance.getUnlockLevels(themeType: themeType) - 1
//      let label = SKLabelNode(text: "\(passedLevels)/25")
//      label.position = CGPoint(x: 0, y: 0)
//      label.verticalAlignmentMode = .Center
//      label.zPosition = 10
//      label.fontName = "ArialRoundedMTBold"
//      label.color = UIColor.whiteColor()
//      label.fontSize = theme.size.width/3.5
//      label.name = "label"
//      theme.addChild(label)
      addLabelToThemeButton(theme, themeType: themeType)
    }else {
      theme.isEnabled = false
    }
    
    
    theme.actionTouchUpInside = {
//      theme.removeAllActions()
      guard self.touchable == true else { return }
      self.touchable = false
      SKTAudio.sharedInstance().playSoundEffect("energy_4.wav")
      let action = SKAction.sequence([
        SKAction.scale(to: 0, duration: 0.2),
        SKAction.run{
          theme.removeFromParent()
//          theme.setScale(1)
          self.addLevelSelectButtons(theme.position, themeType: themeType)
          self.addBackButton()
          
          self.touchable = true
        }
      ])
      theme.run(action)
      for themeButton in self.themeButtons where themeButton != theme {
        themeButton.run(SKAction.sequence([
          SKAction.fadeOut(withDuration: 0.2),
          SKAction.run {
            themeButton.removeAllActions()
            themeButton.removeFromParent()
//            themeButton.alpha = 1
          }
        ]))
      }
    }
    theme.alpha = 0
    theme.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.fadeIn(withDuration: 1)]))
    
    return theme
  }
  
  func fromDiySceneAnimation() {
    for button in themeButtons {
      if button.parent == nil {
        return
      }
    }
    for button in themeButtons {
      let scaleAction = SKAction.scale(to: 1, duration: 0.44)
      let fadeInAction = SKAction.fadeIn(withDuration: 0.44)
      button.run(SKAction.group([scaleAction, fadeInAction]))
    }
  }
  
  // Level select buttons
  func addLevelSelectButtons(_ fromePositon: CGPoint, themeType: ThemeType) {
//    var levelSelectButtons = [[SKButtonNode]]()
    levelSelectButtons.removeAll(keepingCapacity: true)
    levelSelectButtons.reserveCapacity(25)
    for row in 0..<5 {
      for column in 0..<5 {
        let button = SKButtonNode(imageNameNormal: "levelSelectButton", selected: "levelSelectButton_selected", disabled: "levelSelectButton_disabled")
        button.highlightTexture = SKTexture(imageNamed: "playingLevelButton")
        button.position.x = self.size.width/2 + CGFloat(column-2) * (70+button.size.width)
        button.position.y = self.size.height/2 - CGFloat(row-2) * (70+button.size.height)
        button.name = "levelSelectButton"
        button.zPosition = 500
        let currentLevel = row*5 + column + 1
//        button.actionTouchUpInside = levelButtonSelectAction(currentLevel)
        button.actionTouchUpInside = {
          guard self.touchable else { return }
          self.touchable = false
          SKTAudio.sharedInstance().playSoundEffect("fadeout.mp3")
          let sequenceAction = SKAction.sequence([
            SKAction.group([
              SKAction.scale(to: 3, duration: 0.3),
              SKAction.fadeOut(withDuration: 0.3)
              ]),
            SKAction.run{
              SKTAudio.sharedInstance().playBackgroundMusic("background_play.mp3")
              self.fromThemeType = themeType
              SceneManager.sharedInstance.showLevelScene(themeType, level: currentLevel)
              self.touchable = true
              button.isSelected = false
            }
            
            ])
          button.run(sequenceAction)
          for levelSelectButton in self.levelSelectButtons where levelSelectButton != button {
              levelSelectButton.run(SKAction.fadeOut(withDuration: 0.3))
          }
        }
        button.isEnabled = currentLevel < LevelManager.shareInstance.getUnlockLevels(themeType: themeType)
        if currentLevel == LevelManager.shareInstance.getUnlockLevels(themeType: themeType) {
          
          button.selectedTexture = SKTexture(imageNamed: "playingLevelButton_selected")
          button.isEnabled = true
          button.isHighlight = true
        }
        button.zPosition = 10000
        addChild(button)
        levelSelectButtons.append(button)
      }
    }
    animationLevelSelectButtons(fromePositon)
  }
  
  func updateSelectButtonsState() {
    guard let fromThemeType = self.fromThemeType else { return }
    let restButtonAnimatioinDuration: TimeInterval = 0.6
    for button in levelSelectButtons {
      let fadeInAction = SKAction.fadeIn(withDuration: restButtonAnimatioinDuration)
      fadeInAction.timingMode = SKActionTimingMode.easeIn
      if button.xScale == 1 {
        let action = SKAction.sequence([
          SKAction.wait(forDuration: 0.3),
          SKAction.fadeIn(withDuration: 0.6)
          ])
        button.run(action)
      }else {
        let sceleAction = SKAction.scale(to: 1, duration: restButtonAnimatioinDuration)
        sceleAction.timingMode = SKActionTimingMode.easeOut
        let action = SKAction.group([
          sceleAction,
          fadeInAction
          ])
        action.timingMode = SKActionTimingMode.easeInEaseOut
        button.run(action)
      }
    }
    
    let unlockedLevels = LevelManager.shareInstance.getUnlockLevels(themeType: fromThemeType)
    
    for (index, button) in levelSelectButtons.enumerated() where index+1 <= unlockedLevels {
      if button.isHighlight && index+1 != unlockedLevels {
        let actoin = SKAction.sequence([
          SKAction.wait(forDuration: restButtonAnimatioinDuration),
          SKAction.scale(to: 0, duration: 0.33),
          SKAction.run {
            button.selectedTexture = SKTexture(imageNamed: "levelSelectButton_selected")
            button.isHighlight = false
            button.isEnabled = true
          },
          SKAction.scale(to: 1, duration: 0.33)
          ])
        button.run(actoin)
      }
      if button.isEnabled == false {
        let actoin = SKAction.sequence([
          SKAction.wait(forDuration: restButtonAnimatioinDuration),
          SKAction.scale(to: 0, duration: 0.33),
          SKAction.run {
            button.isEnabled = true
            if index + 1 == unlockedLevels {
              button.selectedTexture = SKTexture(imageNamed: "playingLevelButton_selected")
              button.isHighlight = true
            }
          },
          SKAction.scale(to: 1, duration: 0.33)
        ])
        button.run(actoin)
      }
      
    }
  }
  
  func animationLevelSelectButtons(_ fromPosition: CGPoint) {
    enumerateChildNodes(withName: "//levelSelectButton") { node, _ in
      guard let node = node as? SKSpriteNode else { return }
      let originalPosition = node.position
      node.position = fromPosition
      node.setScale(0)
      var factor: Double = 900
      if fromPosition.x == 768 {
        factor = 500
      }
      var distance = TimeInterval((fromPosition - originalPosition).length()) / factor
      node.zPosition = node.zPosition - CGFloat(distance)
      if distance < 0.2 { distance = 0.2 }
      let scaleAction0 = SKAction.scale(to: 1.15, duration: distance)
      let scaleAction1 = SKAction.scale(to: 0.85, duration: 0.33)
      let scaleAction2 = SKAction.scale(to: 1, duration: 0.33)

      scaleAction1.timingMode = SKActionTimingMode.easeInEaseOut
      scaleAction2.timingMode = SKActionTimingMode.easeInEaseOut
      
      
      let moveAction = SKAction.move(to: originalPosition, duration: distance)

      let moveAndScleAction = SKAction.group([moveAction, scaleAction0])
      moveAndScleAction.timingMode = SKActionTimingMode.easeInEaseOut

      node.run(SKAction.sequence([moveAndScleAction, scaleAction1, scaleAction2]))
    }
  }
  
  func restAnimationLevelSelectButtonsAndThemesButton(_ selectedThemeButton: SKButtonNode) {
    var maxAnimationDuration: TimeInterval = 0
    enumerateChildNodes(withName: "//levelSelectButton") { node, _ in
      guard let node = node as? SKSpriteNode else { return }
      let originalPosition = node.position
      let toPosition = selectedThemeButton.position
      var factor: Double = 900
      if toPosition.x == 768 {
        factor = 500
      }
      var duration = TimeInterval((toPosition - originalPosition).length()) / factor
      //Make the far away node is under the close node
      node.zPosition = node.zPosition - CGFloat(duration)
      if duration < 0.2 { duration = 0.2 }
      maxAnimationDuration = max(duration, maxAnimationDuration)
      let scaleAction0 = SKAction.scale(to: 0, duration: duration)
      
      let moveAction = SKAction.move(to: toPosition, duration: duration)
      
      let moveAndScleAction = SKAction.group([moveAction, scaleAction0])
      moveAndScleAction.timingMode = SKActionTimingMode.easeInEaseOut
      
      node.run(SKAction.sequence([moveAndScleAction, SKAction.run{ node.removeFromParent() }]))
    }
    overlayNode.addChild(selectedThemeButton)
    let scaleAction1 = SKAction.scale(to: 0.95, duration: 0.11)
    let scaleAction2 = SKAction.scale(to: 1, duration: 0.11)
    selectedThemeButton.run(SKAction.sequence([SKAction.wait(forDuration: maxAnimationDuration), SKAction.scale(to: 1.05, duration: 0.33), scaleAction1, scaleAction2]))
    for buttonNode in themeButtons where buttonNode != selectedThemeButton{
//      print(buttonNode.parent)
      self.overlayNode.addChild(buttonNode)
      buttonNode.alpha = 0
      let waitAction = SKAction.wait(forDuration: maxAnimationDuration)
      let fadeInAction = SKAction.fadeIn(withDuration: 0.55)
      fadeInAction.timingMode = SKActionTimingMode.easeInEaseOut
      buttonNode.run(SKAction.sequence([waitAction, fadeInAction]))
//      buttonNode.alpha = 1
    }
  }
  
  func addBackButton() {
    let backButton = SKButtonNode(imageNameNormal: "back", selected: nil)
    backButton.name = "back"
    backButton.position = CGPoint(x: xMargin + 108, y: 1950)
    backButton.actionTouchUpInside = {
      SKTAudio.sharedInstance().playSoundEffect("menu_back.wav")
      for themeButton in self.themeButtons where themeButton.xScale == 0 {
        self.restAnimationLevelSelectButtonsAndThemesButton(themeButton)
      }
      self.updateAllThemeButtonInfo()
      backButton.removeFromParent()
    }
    backButton.zPosition = overlayNode.zPosition
    overlayNode.addChild(backButton)
    backButton.alpha = 0
    backButton.run(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.fadeIn(withDuration: 0.66)]))
  }
  
  // Level select action
//  func levelButtonSelectAction(level: Int) -> (()->()) {
//    return {
//
////      if level > 20 {
////        SceneManager.sharedInstance.showLevelScene(level-5)
////      }else {
////        SceneManager.sharedInstance.showLevelScene(level)
////      }
//      SceneManager.sharedInstance.showLevelScene(themeType!, level: <#T##Int#>)
//      
//    }
//  }
  
  // MARK: Touch Event:
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if !touchable { return }
    didTouchedScreen = true
    if let tap = hudNode.childNode(withName: "tap") {
      tap.removeAllActions()
      tap.run(SKAction.fadeOut(withDuration: 0.33))
      
    }
  }
  
  
}

extension StartScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    if collision == PhysicsCategory.Rod | PhysicsCategory.Ball {

    }
  }
}
