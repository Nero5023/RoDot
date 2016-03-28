//
//  StartScene.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/23.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit


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
  
  // MARK: Scene Life Cycle
  
  override func didMoveToView(view: SKView) {
    
    guard isFirstTime else { return }
    isFirstTime = false
    
    setUpNodes()
    
    let maxAspectRatio: CGFloat = 16.0/9.0
    let maxAspectRatioWidth = size.height / maxAspectRatio
    
    let playableMargin: CGFloat = (size.width - maxAspectRatioWidth)/2
    playableRect = CGRect(x: playableMargin, y: 0, width: size.width - playableMargin*2, height: size.height)
    
    let titleLabelNode = childNodeWithName("title")!
    
    titlePositoin = titleLabelNode.position
    titleLabelNode.alpha = 0
    titleLabelNode.runAction(SKAction.fadeAlphaTo(1, duration: 1.5))
  }
  
  func setUpNodes() {
    enumerateChildNodesWithName("//ball", usingBlock: { node, _ in
      let node = node as! StartBallNode
      node.originalPosition = node.position
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
      let scaleToWidth = sqrt(playableRect.width/2*playableRect.width/2+maxSizeBallNode.position.y*maxSizeBallNode.position.y)*2 + 100
      let scaleAction1 = SKAction.resizeToWidth(scaleToWidth, height: scaleToWidth, duration: 0.5)
      scaleAction1.timingMode = SKActionTimingMode.EaseIn
      let runBlock = SKAction.runBlock(addThemeButtons)
      maxSizeBallNode.runAction(SKAction.sequence([scaleAction0, runBlock ,scaleAction1]))
    }
  }
  
  
  // MARK: Actions
  
  // theme button
  func addThemeButtons() {
    var buttons = [SKButtonNode]()
    
    
    let theme1 = SKButtonNode(imageNameNormal: "theme1", selected: "theme1_selected")
    theme1.position = CGPoint(x: 768, y: 1800)
    theme1.zPosition = 1100
    overlayNode.addChild(theme1)
    var positions = [CGPoint]()
    let themeScene = SKScene(fileNamed: "ThemeTitles")!
    for node in themeScene.childNodeWithName("theme1")!.children {
      positions.append(node.position)
    }
    
    theme1.actionTouchUpInside = {
      for position in positions {
        let emitter = Int.random(min: 0, max: 2) == 0 ? SKEmitterNode(fileNamed: "ball_scaleUp")! : SKEmitterNode(fileNamed: "ball_scaleDown")!
        emitter.position = theme1.convertPoint(position, toNode: self)
        emitter.zPosition = 1000
        emitter.particleColor = UIColor.blackColor()
        self.addChild(emitter)
        emitter.runAction(SKAction.afterDelay(0.1, runBlock: {
          emitter.particleBirthRate = 0
        }))
        emitter.runAction(SKAction.afterDelay(3, runBlock: {
          emitter.removeFromParent()
        }))
      }
      theme1.removeFromParent()
      self.addLevelSelectButtons()
//      self.runAction(SKAction.afterDelay(3, runBlock: {
//        theme1.zPosition = 100
//        self.addChild(theme1)
//      }))
    }
    
    buttons.append(theme1)
    
    let diyButton = SKButtonNode(imageNameNormal: "diy", selected: "diy_selected")
    diyButton.position = CGPoint(x: 768, y: 500)
    diyButton.zPosition = 1100
    overlayNode.addChild(diyButton)
    diyButton.actionTouchUp = { [unowned self] in
      let editScene = LevelEditorScene(fileNamed:"LevelEditor")
      editScene?.scaleMode = self.scaleMode
      self.view?.presentScene(editScene)
    }
    
    
  }
  
  // Level select buttons
  func addLevelSelectButtons() {
//    var levelSelectButtons = [[SKButtonNode]]()
    for i in 0..<5 {
      for j in 0..<5 {
        let button = SKButtonNode(imageNameNormal: "levelSelectButton", selected: "levelSelectButton_selected")
        button.position.x = self.size.width/2 + CGFloat(j-2) * (70+button.size.width)
        button.position.y = self.size.height/2 - CGFloat(i-2) * (70+button.size.height)
        button.zPosition = 500
        button.actionTouchUpInside = levelButtonSelectAction(i*5 + j + 1)
        addChild(button)
      }
    }
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
