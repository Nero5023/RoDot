//
//  StartScene.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/23.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit

protocol StartSceneDelegate: class {
  func didSelectMyDiysButton(scene: StartScene)
}

class StartScene: SKScene, SceneLayerProtocol {
  
  // MARK: Properties
  
  let TotalBallNodesCount: Int = 9
  
  var staticBallCount: Int = 0
  
  var playableRect: CGRect!
  
  var titlePositoin: CGPoint!
  
  var didTouchedScreen = false
  var touchable = false
  var maxSizeBallNode: StartBallNode!
  var ballNodes = [StartBallNode]()
  
  var isFirstTime: Bool = true
  
  weak var startSceneDelegate: StartSceneDelegate?
  
  
  var themeButtons = [SKButtonNode]()
  
  var levelSelectButtons = [SKButtonNode]()
  
  let soundBubblePop = SKAction.playSoundFileNamed("fadeout.mp3", waitForCompletion: false)
//  let soundBallBounce = SKAction.playSoundFileNamed("ball_bounce.wav", waitForCompletion: true)
  
  // MARK: Scene Life Cycle
  
  override func didMoveToView(view: SKView) {
    
    guard isFirstTime else {
      updateSelectButtonsState()
      fromDiySceneAnimation()
      return
    }
    isFirstTime = false
    
    setUpRodAndBall()
    
    let maxAspectRatio: CGFloat = 16.0/9.0
    let maxAspectRatioWidth = size.height / maxAspectRatio
    
    let playableMargin: CGFloat = (size.width - maxAspectRatioWidth)/2
    playableRect = CGRect(x: playableMargin, y: 0, width: size.width - playableMargin*2, height: size.height)
    
    let titleLabelNode = childNodeWithName("title")!
    
    titlePositoin = titleLabelNode.position
    titleLabelNode.alpha = 0
    titleLabelNode.runAction(SKAction.fadeAlphaTo(1, duration: 1.5))
  }
  
  
  func setUpRodAndBall() {
    physicsWorld.contactDelegate = self
    enumerateChildNodesWithName("//ball", usingBlock: { node, _ in
      let node = node as! StartBallNode
      node.originalPosition = node.position
      node.zPosition = self.overlayNode.zPosition + 10
      node.position.y = CGFloat.random(min: -300, max: -50)
      let moveUpaction = SKAction.moveTo(node.originalPosition , duration: NSTimeInterval(CGFloat.random(min: 0.8, max: 1.2)))
      moveUpaction.timingMode = SKActionTimingMode.EaseOut
      let waitAction = SKAction.waitForDuration(NSTimeInterval(CGFloat.random(min: 0, max: 0.33)))
      let addPhysicsAction = SKAction.runBlock({
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
      node.runAction(actionSequence)
      
      if self.maxSizeBallNode == nil {
        self.maxSizeBallNode = node
      }else {
        self.maxSizeBallNode = self.maxSizeBallNode.size.width > node.size.width ? self.maxSizeBallNode : node
      }
      self.ballNodes.append(node)
    })
    
    enumerateChildNodesWithName("//rod", usingBlock: { node, _ in
      let node = node as! SKSpriteNode
      node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size)
      node.physicsBody!.affectedByGravity = false
      node.physicsBody!.dynamic = false
      node.physicsBody!.friction = 0
      node.physicsBody!.categoryBitMask = PhysicsCategory.Rod
      node.physicsBody!.collisionBitMask = PhysicsCategory.Ball
      node.physicsBody!.contactTestBitMask = PhysicsCategory.Ball
      node.alpha = 0
    })
  }
  
  // Update
  override func update(currentTime: NSTimeInterval) {
    if paused { return }
    enumerateChildNodesWithName("//ball", usingBlock: { node, _ in
      let node = node as! StartBallNode
      if self.didTouchedScreen {
        if let lastVelocity = node.lastVelocity {
          if lastVelocity.dy <= 0 && node.physicsBody?.velocity.dy > 0{
            let xAction = SKAction.moveToX(self.titlePositoin.x, duration: 0.8)
            let maxY = max(node.originalPosition.y, self.titlePositoin.y)
            let yAction0 = SKAction.moveToY(CGFloat.random(min: maxY+10, max: maxY+50), duration: 0.4)
            let yAction1 = SKAction.moveToY(self.titlePositoin.y, duration: 0.4)
            yAction0.timingMode = SKActionTimingMode.EaseOut
            yAction1.timingMode = SKActionTimingMode.EaseIn
            let addSaticBallCountAction = SKAction.runBlock({
              self.staticBallCount+=1
            })
            node.physicsBody = nil
            let groupAction = SKAction.group([xAction, SKAction.sequence([yAction0, yAction1, addSaticBallCountAction])])
            
            node.runAction(groupAction)
            
          }
        }
      }
      
      node.lastVelocity = node.physicsBody?.velocity
    })
    
    if staticBallCount > 0 && childNodeWithName("title")?.actionForKey("fadeout") == nil{
      let fadeoutAction = SKAction.fadeOutWithDuration(0.5)
      let removeAction = SKAction.runBlock({
        self.childNodeWithName("title")?.removeFromParent()
      })
      childNodeWithName("title")?.runAction(SKAction.sequence([fadeoutAction, removeAction]), withKey: "fadeout")
    }
    
    if staticBallCount == TotalBallNodesCount {
      staticBallCount = 0
      for node in ballNodes {
        if node != maxSizeBallNode {
          node.removeFromParent()
        }
      }
      let scaleAction0 = SKAction.resizeToWidth(20, height: 20, duration: 0.3)
      scaleAction0.timingMode = SKActionTimingMode.EaseOut
      let scaleToWidth = sqrt(playableRect.width/2*playableRect.width/2+maxSizeBallNode.position.y*maxSizeBallNode.position.y)*2 + 200
      let scaleAction1 = SKAction.resizeToWidth(scaleToWidth, height: scaleToWidth, duration: 0.5)
      scaleAction1.timingMode = SKActionTimingMode.EaseIn
      let runBlock = SKAction.runBlock {
        self.addThemeButtons()
        self.addBackground()
//        self.maxSizeBallNode.removeFromParent()
      }
      let runBlock1 = SKAction.runBlock {
        SKTAudio.sharedInstance().playBackgroundMusic("background_music.wav")
      }
      maxSizeBallNode.runAction(SKAction.sequence([scaleAction0, runBlock ,scaleAction1, runBlock1]))
    }
  }
  
  
  // MARK: Actions
  
  
  
  
  func addBackground() {
    let maxAspectRatio: CGFloat = 16.0/9.0
    let maxAspectRatioWidth = size.height / maxAspectRatio
    
    let playableMargin: CGFloat = (size.width - maxAspectRatioWidth)/2
    let playableRect = CGRect(x: playableMargin, y: 0, width: size.width - playableMargin*2, height: size.height)
    let background = SKSpriteNode(texture: SKTexture(imageNamed: "background"))
    background.zPosition = bgNode.zPosition
    background.anchorPoint = CGPoint.zero
    background.position = playableRect.origin
    background.size = playableRect.size
    background.alpha = 0
    bgNode.addChild(background)
    let runblock = SKAction.runBlock{
      self.maxSizeBallNode.zPosition = self.bgNode.zPosition - 10
    }
    
//    print(background.size)
    background.runAction(SKAction.sequence([SKAction.waitForDuration(0.5), runblock, SKAction.fadeInWithDuration(0.5)]))
    maxSizeBallNode.runAction(SKAction.sequence([SKAction.waitForDuration(1), SKAction.fadeOutWithDuration(0.33), SKAction.runBlock{ self.maxSizeBallNode.removeFromParent() }]))
  }
  
  // theme button
  func addThemeButtons() {
    
    themeButtons.reserveCapacity(3)
    let theme1 = addThemeButton(withButtonName: "theme1", position: CGPoint(x: 192 + 528 + 261, y: 1417 + 261))
    themeButtons.append(theme1)
    let theme2 = addThemeButton(withButtonName: "theme2", position: CGPoint(x: 192 + 100 + 213, y: 1013 + 213))
    themeButtons.append(theme2)
    let theme3 = addThemeButton(withButtonName: "theme3", position: CGPoint(x: 192 + 690 + 140, y: 779 + 140))
    themeButtons.append(theme3)
    
    let diyButton = SKButtonNode(imageNameNormal: "diy", selected: "diy_selected")
    diyButton.position = CGPoint(x: 192 + 227 + 210, y: 469 + 210)
    diyButton.zPosition = overlayNode.zPosition 
    overlayNode.addChild(diyButton)
    diyButton.actionTouchUpInside = { [unowned self] in
      let soundClick = SKAction.playSoundFileNamed("diy_click.wav", waitForCompletion: false)
      self.runAction(soundClick)
      let scaleAction = SKAction.scaleTo(0.2, duration: 0.33)
      let fadoutAction = SKAction.fadeOutWithDuration(0.33)
      let scaleAndFadeOutAction = SKAction.group([scaleAction, fadoutAction])
      let runBlock = SKAction.runBlock {
        let editScene = LevelEditorScene(fileNamed:"LevelEditor")
        editScene?.scaleMode = self.scaleMode
        self.view?.presentScene(editScene)
      }
      diyButton.runAction(SKAction.sequence([scaleAndFadeOutAction, runBlock]))
      for button in self.themeButtons where button != diyButton {
        button.runAction(SKAction.fadeOutWithDuration(0.33))
      }
    }
    diyButton.alpha = 0
    diyButton.runAction(SKAction.sequence([SKAction.waitForDuration(0.9), SKAction.fadeInWithDuration(0.5)]))
    
    let myDiybutton = SKButtonNode(imageNameNormal: "mydiy", selected: "mydiy_selected")
    myDiybutton.position = CGPoint(x: 192 + 635 + 120, y: 178 + 120)
    myDiybutton.zPosition = overlayNode.zPosition
    overlayNode.addChild(myDiybutton)
    myDiybutton.actionTouchUpInside = { [unowned self] in
      self.startSceneDelegate?.didSelectMyDiysButton(self)
    }
    myDiybutton.alpha = 0
    myDiybutton.runAction(SKAction.sequence([SKAction.waitForDuration(0.9), SKAction.fadeInWithDuration(0.5)]))
    
    themeButtons.append(diyButton)
    themeButtons.append(myDiybutton)
    
  }
  
  //Help Method
  func addThemeButton(withButtonName name: String, position: CGPoint) -> SKButtonNode {
    let theme = SKButtonNode(imageNameNormal: name, selected: name+"_selected")
    theme.position = position
    theme.zPosition = overlayNode.zPosition
    theme.name = name
    overlayNode.addChild(theme)
    
    
    theme.actionTouchUpInside = {
      self.runAction(SKAction.playSoundFileNamed("energy_4.wav", waitForCompletion: false))
      let action = SKAction.sequence([
        SKAction.scaleTo(0, duration: 0.2),
        SKAction.runBlock{
          theme.removeFromParent()
//          theme.setScale(1)
          self.addLevelSelectButtons(theme.position)
          self.addBackButton()
        }
      ])
      theme.runAction(action)
      for themeButton in self.themeButtons where themeButton != theme {
        themeButton.runAction(SKAction.sequence([
          SKAction.fadeOutWithDuration(0.2),
          SKAction.runBlock {
            themeButton.removeAllActions()
            themeButton.removeFromParent()
//            themeButton.alpha = 1
          }
        ]))
      }
    }
    theme.alpha = 0
    theme.runAction(SKAction.sequence([SKAction.waitForDuration(0.5), SKAction.fadeInWithDuration(0.5)]))
    
    return theme
  }
  
  func fromDiySceneAnimation() {
    for button in themeButtons {
      if button.parent == nil {
        return
      }
    }
    for button in themeButtons {
      let scaleAction = SKAction.scaleTo(1, duration: 0.44)
      let fadeInAction = SKAction.fadeInWithDuration(0.44)
      button.runAction(SKAction.group([scaleAction, fadeInAction]))
    }
  }
  
  // Level select buttons
  func addLevelSelectButtons(fromePositon: CGPoint) {
//    var levelSelectButtons = [[SKButtonNode]]()
    levelSelectButtons.removeAll(keepCapacity: true)
    levelSelectButtons.reserveCapacity(25)
    for row in 0..<5 {
      for column in 0..<5 {
        let button = SKButtonNode(imageNameNormal: "levelSelectButton", selected: "levelSelectButton_selected", disabled: "levelSelectButton_disabled")
        button.position.x = self.size.width/2 + CGFloat(column-2) * (70+button.size.width)
        button.position.y = self.size.height/2 - CGFloat(row-2) * (70+button.size.height)
        button.name = "levelSelectButton"
        button.zPosition = 500
        let currentLevel = row*5 + column + 1
//        button.actionTouchUpInside = levelButtonSelectAction(currentLevel)
        button.actionTouchUpInside = {
          guard self.touchable else { return }
          self.touchable = false
          self.runAction(self.soundBubblePop)
          let sequenceAction = SKAction.sequence([
            SKAction.group([
              SKAction.scaleTo(3, duration: 0.3),
              SKAction.fadeOutWithDuration(0.3)
              ]),
            SKAction.runBlock{
              self.levelButtonSelectAction(currentLevel)()
              self.touchable = true
              button.isSelected = false
            }
            
            ])
          button.runAction(sequenceAction)
          for levelSelectButton in self.levelSelectButtons where levelSelectButton != button {
              levelSelectButton.runAction(SKAction.fadeOutWithDuration(0.3))
          }
        }
        button.isEnabled = currentLevel <= LevelManager().getUnlockLevels(theme: .Theme1)
        addChild(button)
        levelSelectButtons.append(button)
      }
    }
    animationLevelSelectButtons(fromePositon)
  }
  
  func updateSelectButtonsState() {
    let restButtonAnimatioinDuration: NSTimeInterval = 0.6
    for button in levelSelectButtons {
      let fadeInAction = SKAction.fadeInWithDuration(restButtonAnimatioinDuration)
      fadeInAction.timingMode = SKActionTimingMode.EaseIn
      if button.xScale == 1 {
        let action = SKAction.sequence([
          SKAction.waitForDuration(0.3),
          SKAction.fadeInWithDuration(0.6)
          ])
        button.runAction(action)
      }else {
        let sceleAction = SKAction.scaleTo(1, duration: restButtonAnimatioinDuration)
        sceleAction.timingMode = SKActionTimingMode.EaseOut
        let action = SKAction.group([
          sceleAction,
          fadeInAction
          ])
        action.timingMode = SKActionTimingMode.EaseInEaseOut
        button.runAction(action)
      }
    }
    
    let unlockedLevels = LevelManager().getUnlockLevels(theme: .Theme1)
    for (index, button) in levelSelectButtons.enumerate() where index+1 <= unlockedLevels {
      if button.isEnabled == false {
        let actoin = SKAction.sequence([
          SKAction.waitForDuration(restButtonAnimatioinDuration),
          SKAction.scaleTo(0, duration: 0.33),
          SKAction.runBlock { button.isEnabled = true},
          SKAction.scaleTo(1, duration: 0.33)
        ])
        button.runAction(actoin)
      }
      
    }
  }
  
  func animationLevelSelectButtons(fromPosition: CGPoint) {
    enumerateChildNodesWithName("//levelSelectButton") { node, _ in
      guard let node = node as? SKSpriteNode else { return }
      let originalPosition = node.position
      node.position = fromPosition
      node.setScale(0)
      var factor: Double = 900
      if fromPosition.x == 768 {
        factor = 500
      }
      var distance = NSTimeInterval((fromPosition - originalPosition).length()) / factor
      node.zPosition = node.zPosition - CGFloat(distance)
      if distance < 0.2 { distance = 0.2 }
      let scaleAction0 = SKAction.scaleTo(1.15, duration: distance)
      let scaleAction1 = SKAction.scaleTo(0.85, duration: 0.33)
      let scaleAction2 = SKAction.scaleTo(1, duration: 0.33)

      scaleAction1.timingMode = SKActionTimingMode.EaseInEaseOut
      scaleAction2.timingMode = SKActionTimingMode.EaseInEaseOut
      
      
      let moveAction = SKAction.moveTo(originalPosition, duration: distance)

      let moveAndScleAction = SKAction.group([moveAction, scaleAction0])
      moveAndScleAction.timingMode = SKActionTimingMode.EaseInEaseOut

      node.runAction(SKAction.sequence([moveAndScleAction, scaleAction1, scaleAction2]))
    }
  }
  
  func restAnimationLevelSelectButtonsAndThemesButton(selectedThemeButton: SKButtonNode) {
    var maxAnimationDuration: NSTimeInterval = 0
    enumerateChildNodesWithName("//levelSelectButton") { node, _ in
      guard let node = node as? SKSpriteNode else { return }
      let originalPosition = node.position
      let toPosition = selectedThemeButton.position
      var factor: Double = 900
      if toPosition.x == 768 {
        factor = 500
      }
      var duration = NSTimeInterval((toPosition - originalPosition).length()) / factor
      //Make the far away node is under the close node
      node.zPosition = node.zPosition - CGFloat(duration)
      if duration < 0.2 { duration = 0.2 }
      maxAnimationDuration = max(duration, maxAnimationDuration)
      let scaleAction0 = SKAction.scaleTo(0, duration: duration)
      
      let moveAction = SKAction.moveTo(toPosition, duration: duration)
      
      let moveAndScleAction = SKAction.group([moveAction, scaleAction0])
      moveAndScleAction.timingMode = SKActionTimingMode.EaseInEaseOut
      
      node.runAction(SKAction.sequence([moveAndScleAction, SKAction.runBlock{ node.removeFromParent() }]))
    }
    overlayNode.addChild(selectedThemeButton)
    let scaleAction1 = SKAction.scaleTo(0.95, duration: 0.11)
    let scaleAction2 = SKAction.scaleTo(1, duration: 0.11)
    selectedThemeButton.runAction(SKAction.sequence([SKAction.waitForDuration(maxAnimationDuration), SKAction.scaleTo(1.05, duration: 0.33), scaleAction1, scaleAction2]))
    for buttonNode in themeButtons where buttonNode != selectedThemeButton{
//      print(buttonNode.parent)
      self.overlayNode.addChild(buttonNode)
      buttonNode.alpha = 0
      let waitAction = SKAction.waitForDuration(maxAnimationDuration)
      let fadeInAction = SKAction.fadeInWithDuration(0.55)
      fadeInAction.timingMode = SKActionTimingMode.EaseInEaseOut
      buttonNode.runAction(SKAction.sequence([waitAction, fadeInAction]))
//      buttonNode.alpha = 1
    }
  }
  
  func addBackButton() {
    let backButton = SKButtonNode(imageNameNormal: "back", selected: nil)
    backButton.name = "back"
    backButton.position = CGPoint(x: 300, y: 1950)
    backButton.actionTouchUpInside = {
      SKTAudio.sharedInstance().playSoundEffect("menu_back.wav")
      for themeButton in self.themeButtons where themeButton.xScale == 0 {
        self.restAnimationLevelSelectButtonsAndThemesButton(themeButton)
      }
      
      backButton.removeFromParent()
    }
    backButton.zPosition = overlayNode.zPosition
    overlayNode.addChild(backButton)
    backButton.alpha = 0
    backButton.runAction(SKAction.fadeInWithDuration(0.66))
  }
  
  // Level select action
  func levelButtonSelectAction(level: Int) -> (()->()) {
    return {

      if level > 20 {
        SceneManager.sharedInstance.showLevelScene(level-5)
      }else {
        SceneManager.sharedInstance.showLevelScene(level)
      }
      
    }
  }
  
  // MARK: Touch Event:
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    if !touchable { return }
    didTouchedScreen = true
    
  }
  
  
}

extension StartScene: SKPhysicsContactDelegate {
  func didBeginContact(contact: SKPhysicsContact) {
    let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    if collision == PhysicsCategory.Rod | PhysicsCategory.Ball {

    }
  }
}
