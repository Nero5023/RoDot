//
//  LevelScene.swift
//  Grid
//
//  Created by Nero Zuo on 16/2/28.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

private let RestartGameActionKey = "RestartGame"

class LevelScene: SKScene, SceneLayerProtocol {
  
  // MARK: Properties
  
  var entities = Set<GKEntity>()
  
  var lastUpdateTimeInterval: NSTimeInterval = 0
  
  lazy var componentSystems: [GKComponentSystem] = {
  let moveSystem = GKComponentSystem(componentClass: MoveComponent.self)
    
    return [moveSystem]
  }()
  
  var moveableInputComponent: InputComponent?
  
  // In the didSimulatePhysics do the block
  var restRotatingCompletionBlock: (()->())?

  var isResting: Bool = false
  
  var currentLevel: Int = 0
  var theme: ThemeType = .Theme1
  
  var playable: Bool = false
  
  var rotateCount = 0
  
  var stopRecordingCompletionHandler: (()->())?
  
  var isFinishAnimation: Bool = false
  // Class Methods:
  
  class func level(levelNum: Int) -> LevelScene? {
    let scene = LevelScene(fileNamed: "Level\(levelNum)")!
    scene.currentLevel = levelNum
    scene.scaleMode = .AspectFill
    return scene
  }
  
  class func themeLevel(theme: ThemeType, levelNum: Int) -> LevelScene? {
    let scene = LevelScene(fileNamed: "Theme\(theme.themeNum)_\(levelNum)")!
    scene.currentLevel = levelNum
    scene.theme = theme
    scene.scaleMode = .AspectFill
    return scene
  }

  // MARK: Scene Life Cycle
  
  override func didMoveToView(view: SKView) {
    setUpScene()
    
    physicsWorld.contactDelegate = self
    
    enumerateChildNodesWithName("//*", usingBlock: { [unowned self] node, _  in
      if let node = node as? RodNode {
       let entity =  Rod(renderNode: node)
        node.removeFromParent()
        self.addEntity(entity)
      }
      if let node = node as? RotationPointNode  {
        
        let nodeType = PointNodeType(nodeName: node.name)

        node.removeFromParent()
        self.addEntity(nodeType.pointEntity(node))
      }
      
      
      if let ballNode = node as? BallNode {
        ballNode.didMoveToScene()
      }
      if let iceball = node as? IceBallNode {
        iceball.didMoveToScene()
      }
      if let destination = node as? DestinationNode {
        destination.didMoveToScene()
      }
      
      if let nodeName = node.name, node = node as? TransferNode {
        if nodeName.hasPrefix("transfer") {
          let entity = Transfer(renderNode: node)
          node.removeFromParent()
          self.addEntity(entity)
          let renderNode = entity.componentForClass(RenderComponent.self)!.node
          renderNode.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(2*π, duration: 2)))
          renderNode.setScale(0)
          let scaleAction = SKAction.scaleTo(1, duration: 0.66)
          scaleAction.timingMode = SKActionTimingMode.EaseOut
          renderNode.runAction(SKAction.sequence([SKAction.waitForDuration(1), scaleAction]))
          
        }
      }
      
    })
    
    for entity in entities {
      if let intelligenceComponent = entity.componentForClass(IntelligenceComponent.self) {
        intelligenceComponent.enterInitialState()
      }else {
        entity.componentForClass(RelateComponent.self)?.updateRelatedNodes()
      }
    }
    initializeAnimation()
    addTopRootRectangle()
    addBackButton()
    addRestartButton()
    addRecordButton()
    
    
    setUpPointDetail()
    
    animationInstractions()
  }
  
  func setUpPointDetail() {
    for entity in entities {
      entity.componentForClass(RotatableRodCountComponent.self)?.addBubbles()
      entity.componentForClass(ClockwiseComponent.self)?.animationBubble()
    }
  }
  
  func addTopRootRectangle() {
    let upRectangle = SKSpriteNode(texture: nil, color: UIColor(red: 0, green: 0, blue: 0, alpha: 0), size: CGSize(width: self.size.width, height: 20))
    upRectangle.physicsBody = SKPhysicsBody(rectangleOfSize: upRectangle.size)
    upRectangle.physicsBody?.categoryBitMask = PhysicsCategory.Rod
    upRectangle.physicsBody?.collisionBitMask = PhysicsCategory.Ball
    upRectangle.physicsBody!.dynamic = false
    upRectangle.position = CGPoint(x: self.size.width/2, y: self.size.height)
    childNodeWithName("Sprites")?.addChild(upRectangle)
  }
  
  func addBackButton() {
    let backButton = SKButtonNode(imageNameNormal: "back", selected: nil)
    backButton.name = "back"
    backButton.position = CGPoint(x: 108 + xMargin, y: 1950)
    backButton.actionTouchUpInside = backButtonTouchUpInsideActon
    backButton.zPosition = overlayNode.zPosition
    overlayNode.addChild(backButton)
  }
  
  func backButtonTouchUpInsideActon() {
    guard self.isFinishAnimation && self.playable else { return }
    SKTAudio.sharedInstance().playSoundEffect("menu_back.wav")
    if self.isRecording {
      self.stopRecordingCompletionHandler = {
        SceneManager.sharedInstance.backToStartScene()
      }
      self.stopRecording(self.overlayNode.childNodeWithName("record") as! SKButtonNode)
    }else {
      SceneManager.sharedInstance.backToStartScene()
    }
  }
  
  func addRestartButton() {
    let restartButton = SKButtonNode(imageNameNormal: "restart", selected: nil)
    restartButton.position = CGPoint(x: size.width - xMargin - 108, y: 1950)
    restartButton.name = "restart"
    restartButton.actionTouchUpInside = { [unowned self] in
      if self.actionForKey(RestartGameActionKey) == nil {
        SKTAudio.sharedInstance().playSoundEffect("restart_click.wav")
        self.newGame()
      }
    }
    restartButton.zPosition = overlayNode.zPosition
    overlayNode.addChild(restartButton)
    restartButton.alpha = 0
    restartButton.runAction(SKAction.fadeInWithDuration(0.66))
  }
  

  
  func initializeAnimation() {
    for entity in entities {
      if let entity = entity as? BasePointEntity {
        let node = entity.componentForClass(RenderComponent.self)!.node
        node.setScale(0.01)
        let action0 = SKAction.scaleTo(1.15, duration: 1)
        let action1 = SKAction.scaleTo(0.85, duration: 0.5)
        let action2 = SKAction.scaleTo(1, duration: 0.5)
        action0.timingMode = SKActionTimingMode.EaseInEaseOut
        action1.timingMode = SKActionTimingMode.EaseInEaseOut
        action2.timingMode = SKActionTimingMode.EaseInEaseOut
        node.runAction(SKAction.sequence([action0, action1, action2]))
      }
      if let entity = entity as? Rod {
        let node = entity.componentForClass(RenderComponent.self)!.node
        let originalPosition = node.position
        let originalZRotation = node.zRotation
        node.position = CGPoint(x: CGFloat.random(min: 105, max: 1536-105), y: CGFloat.random(min: -200, max: -105))
        node.zRotation = CGFloat.random(min: 0, max: 360).degreesToRadians()
        
        let duration = NSTimeInterval(CGFloat.random(min: 0.8, max: 1.7))
        
        let action0 = SKAction.rotateToAngle(originalZRotation, duration: duration)
        let action1 = SKAction.moveTo(originalPosition, duration: duration)
        action0.timingMode = SKActionTimingMode.EaseInEaseOut
        action1.timingMode = SKActionTimingMode.EaseInEaseOut
        node.runAction(SKAction.group([action0, action1]))
      }
    }
    let ball = spritesNode.childNodeWithName("ball")!
    ball.setScale(0.01)
    ball.physicsBody?.affectedByGravity = false
    ball.physicsBody = nil
    let blackHole = SKSpriteNode(imageNamed: "destination")
    blackHole.position = ball.position
    blackHole.position = ball.position
    blackHole.zPosition = ball.zPosition - 10
    spritesNode.addChild(blackHole)
    blackHole.setScale(0)
    blackHole.runAction(SKAction.sequence([
      SKAction.waitForDuration(1.1),
      SKAction.scaleTo(1.15, duration: 0.33),
      SKAction.fadeOutWithDuration(0.66),
      SKAction.runBlock {
        blackHole.removeFromParent()
      }
      ]))
    let action = SKAction.sequence([SKAction.waitForDuration(1.4),
      SKAction.scaleTo(1, duration: 0.3),
      SKAction.runBlock({ [unowned self] in
      (ball as? BallNode)?.didMoveToScene()
      self.playable = true
      self.isFinishAnimation = true
    })])
    ball.runAction(action)
  }
  
  func setUpScene() {
    physicsBody = SKPhysicsBody(edgeLoopFromRect: backgroundRect)
    physicsBody!.categoryBitMask = PhysicsCategory.Edge
    physicsBody!.collisionBitMask = PhysicsCategory.Ball
    
    addBackground()
  }
  
  func addBackground() {
    let background = SKSpriteNode(texture: SKTexture(imageNamed: "background"))
    background.zPosition = bgNode.zPosition
    background.anchorPoint = CGPoint.zero
    background.size = backgroundRect.size
    background.position = backgroundRect.origin
    bgNode.addChild(background)
  }
  
  // MARK: Instractions
  func animationInstractions() {
    let waitAction = SKAction.waitForDuration(2)
    let fadeInAction = SKAction.fadeInWithDuration(0.33)
    let fadeOutAction = SKAction.fadeOutWithDuration(0.33)
    if let fingerCircle = hudNode.childNodeWithName("finger_circle"), let pathCircle = hudNode.childNodeWithName("path_circle"){
      fingerCircle.alpha = 0
      let rotateAction = SKAction.rotateByAngle(-π/2, duration: 1)
      rotateAction.timingMode = .EaseInEaseOut
      let restZRotation = SKAction.runBlock { fingerCircle.zRotation = 0 }
      let totalRotateAction = SKAction.repeatAction(SKAction.sequence([fadeInAction ,rotateAction, fadeOutAction, restZRotation]), count: 3)
      
      fingerCircle.runAction(SKAction.sequence([
        waitAction, fadeInAction, totalRotateAction
        ]))
      fingerCircle.zPosition = hudNode.zPosition
      pathCircle.zPosition = hudNode.zPosition
      pathCircle.alpha = 0
      pathCircle.runAction(SKAction.sequence([waitAction, fadeInAction]))
    }
    if let fingerLine = hudNode.childNodeWithName("finger_line"), let pathLine = hudNode.childNodeWithName("path_line") as? SKSpriteNode {
      fingerLine.zPosition = hudNode.zPosition
      fingerLine.alpha = 0
      let originalPosition = fingerLine.position
      let moveAction = SKAction.moveToX(pathLine.position.x + pathLine.size.width/2, duration: 1)
      moveAction.timingMode = .EaseInEaseOut
      let restPositon = SKAction.runBlock { fingerLine.position =  originalPosition}
      let totalMoveAction = SKAction.repeatAction(SKAction.sequence([fadeInAction ,moveAction, fadeOutAction, restPositon]), count: 3)
      fingerLine.runAction(SKAction.sequence([
        waitAction, fadeInAction, totalMoveAction
        ]))
      
      pathLine.zPosition = hudNode.zPosition
      pathLine.alpha = 0
      pathLine.runAction(SKAction.sequence([waitAction, fadeInAction]))
    }
    
    if let instructionNode = hudNode.childNodeWithName("instraction") {
      instructionNode.alpha = 0
      instructionNode.runAction(SKAction.sequence([waitAction, fadeInAction]))
    }
  }
  
  
  // MARK: Touch Event
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard touches.count == 1 else { return }
    guard let firstTouchPosition = touches.first?.locationInNode(spritesNode) else { return }
    guard moveableInputComponent == nil else { return }
    guard isResting == false else { return }
    guard playable else { return }
    if let entityNode = spritesNode.nodeAtPoint(firstTouchPosition) as? EntityNode,
        let inputComponent = entityNode.entity.componentForClass(InputComponent.self) {
          moveableInputComponent = inputComponent
        inputComponent.touchesBegan(touches, withEvent: event)
    }
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard touches.count == 1 else { return }
    guard let firstTouchPosition = touches.first?.locationInNode(spritesNode) else { return }
    guard isResting == false else { return }
    guard playable else { return }
    if let moveableInputComponent = moveableInputComponent {
      moveableInputComponent.touchesMoved(touches, withEvent: event)
    }else {
      if let entityNode = spritesNode.nodeAtPoint(firstTouchPosition) as? EntityNode,
        let inputComponent = entityNode.entity.componentForClass(InputComponent.self) {
          moveableInputComponent = inputComponent
          inputComponent.touchesBegan(touches, withEvent: event)
      }
    }
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard isResting == false else { return }
    moveableInputComponent?.touchesEnded(touches, withEvent: event)
    moveableInputComponent = nil
  }
  
  override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    guard isResting == false else { return }
    moveableInputComponent?.touchesEnded([], withEvent: event)
    moveableInputComponent = nil
  }
  
  // Mark: Scene Life Cycle
  
  // Update
  override func update(currentTime: NSTimeInterval) {
    super.update(currentTime)
    
    guard view != nil else { return }
    
    let deltaTime = currentTime - lastUpdateTimeInterval
    lastUpdateTimeInterval = currentTime
    
    
    if paused { return }
    
    for componentSystem in componentSystems {
      componentSystem.updateWithDeltaTime(deltaTime)
    }
    
  }
  
  override func didSimulatePhysics() {
    if let restRotatingCompletionBlock = restRotatingCompletionBlock {
      // Every time when finish rotate, call this
      restRotatingCompletionBlock()
      physicsWorld.removeAllJoints()
      self.restRotatingCompletionBlock = nil
      isResting = false
      rotateCount += 1
    }
  }
  
  // MARK: Convenience Methods
  
  func addEntity(entity: GKEntity) {
    entities.insert(entity)
    
    for componentSystem in componentSystems {
      componentSystem.addComponentWithEntity(entity)
      
    }
    
    if let renderNode = entity.componentForClass(RenderComponent.self)?.node {
        addNode(renderNode, toLayer: spritesNode)
    }
    
//    if let intelligenceComponent = entity.componentForClass(IntelligenceComponent.self) {
//      intelligenceComponent.enterInitialState()
//    }
  }
  
  
  func addNode(node: SKNode, toLayer layerNode: SKNode) {
    layerNode.addChild(node)
  }
  
  // MARK: Game Life Cycle
  
  func newGame() {
    let scene = LevelScene.themeLevel(theme, levelNum: currentLevel)
    scene!.scaleMode = scaleMode
    view!.presentScene(scene)
    GameKitHelper.shareInstance.reportAchievements(AchievementsHelper.rotateAchievements(rotateCount))
    LeaderboardHelper.reportMostRotateTimesToLeaderboard()
  }
  
  func fadeOutRecordRestartButton() {
    let waitAction = SKAction.waitForDuration(0.33)
    let fadeoutAction = SKAction.fadeOutWithDuration(0.66)
    let action = SKAction.sequence([waitAction, fadeoutAction])
    overlayNode.childNodeWithName("restart")?.runAction(action)
    overlayNode.childNodeWithName("record")?.runAction(action)
  }
  
  func lose() {
    playable = false
    SKTAudio.sharedInstance().playSoundEffect("failure.wav")
//    performSelector(#selector(LevelScene.newGame), withObject: nil, afterDelay: 1)
    runAction(SKAction.sequence(
      [SKAction.waitForDuration(1), SKAction.runBlock{[unowned self] in self.newGame() }]),
              withKey: RestartGameActionKey)
  }
  
  func win() {
    playable = false
    
    SKTAudio.sharedInstance().playSoundEffect("success.wav")
    
    fadeOutRecordRestartButton()
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
    
    if currentLevel < theme.themeTotalLevels { // It's hard c
      LevelManager.shareInstance.passLevel(theme: theme, level: currentLevel)
      currentLevel += 1
    }else if currentLevel == theme.themeTotalLevels {
      playable = true
      LevelManager.shareInstance.passLevel(theme: theme, level: currentLevel)
      backButtonTouchUpInsideActon()
      return
    }
    
    if currentLevel >= 10 {
      switch theme {
      case .Theme1:
        LevelManager.shareInstance.unLockTheme(.Theme2)
      case .Theme2:
        LevelManager.shareInstance.unLockTheme(.Theme3)
      default:
        break
      }
    }
    
    performSelector(#selector(LevelScene.newGame), withObject: nil, afterDelay: 1)
  }
}

// MARK: SKPhysicsContactDelegate

extension LevelScene: SKPhysicsContactDelegate {
  
  func didBeginContact(contact: SKPhysicsContact) {
    let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    if collision == PhysicsCategory.Ball | PhysicsCategory.Transfer {
      let transfer = contact.bodyA.categoryBitMask == PhysicsCategory.Transfer ? contact.bodyA.node : contact.bodyB.node
      let ball = contact.bodyA.categoryBitMask == PhysicsCategory.Ball ? contact.bodyA.node : contact.bodyB.node
      if let transfer = transfer as? EntityNode, ball = ball as? SKSpriteNode {
        transfer.entity.componentForClass(TransferComponent.self)?.transferNode(ball)
        SKTAudio.sharedInstance().playSoundEffect("teleport.wav")
      }
    }
    // 可以用 collision & PhysicsCategory.Transfer 看看是不是 Transfer 
    if collision == PhysicsCategory.IceBall | PhysicsCategory.Transfer {
      let transfer = contact.bodyA.categoryBitMask == PhysicsCategory.Transfer ? contact.bodyA.node : contact.bodyB.node
      if let transfer = transfer as? EntityNode {
        (transfer.entity as! FreezableProtocol).setNodeIsFreezed(true)
      }
    }
    
    
    
    if !playable { return }
    
    if collision == PhysicsCategory.Ball | PhysicsCategory.Distance {
      print("win")
      (overlayNode.childNodeWithName("restart") as? SKButtonNode)?.isEnabled = false
      let ball = contact.bodyA.categoryBitMask == PhysicsCategory.Ball ? contact.bodyA.node : contact.bodyB.node
      let distance = contact.bodyA.categoryBitMask == PhysicsCategory.Distance ? contact.bodyA.node : contact.bodyB.node
      ball!.physicsBody = nil
      ball!.runAction(SKAction.group([SKAction.moveTo(distance!.position, duration: 0.8), SKAction.scaleTo(0.01, duration: 0.8)]))
      distance?.runAction(SKAction.sequence([SKAction.waitForDuration(0.7), SKAction.scaleBy(0, duration: 0.4)]))
      
      playable = false
      touchesEnded([], withEvent: nil)
      afterDelay(0.5, runBlock: {
        self.win()
      })
    }
    
    if collision == PhysicsCategory.Ball | PhysicsCategory.Edge {
      print("Lose")
      lose()
    }
    
  }
  
  func didEndContact(contact: SKPhysicsContact) {
    let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    if collision == PhysicsCategory.Ball | PhysicsCategory.Transfer {
      let transfer = contact.bodyA.categoryBitMask == PhysicsCategory.Transfer ? contact.bodyA.node : contact.bodyB.node
      if let transfer = transfer as? EntityNode {
        transfer.entity.componentForClass(TransferComponent.self)?.endTransfer()
      }
    }
  }
}


