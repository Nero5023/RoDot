//
//  LevelEditorScene.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/18.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

class LevelEditorScene: SKScene {
  
  // MARK: Properties
  
  var spritesNode: SKNode {
    guard let spritesNode = childNodeWithName("Sprites") else {
      fatalError("The LevelEditScene must have the node named Sprites")
    }
    return spritesNode
  }
  
  var overlayNode: SKNode {
    guard let overlayNode = childNodeWithName("Overlay") else {
      fatalError("The LevelEditScene have Overlay")
    }
    return overlayNode
  }
  
  var rotatableCount: String?
  var clockwise: String?
  var rotateCount: String?
  var nodeType: String? {
    didSet {
      if let nodeType = nodeType {
        if nodeType != "point" {
          rotateCount = nil
          rotatableCount = nil
          clockwise = nil
          if nodeType == "static" || nodeType == "translation"{
            for button in pointButtons {
              if button.type == nil {
                button.selectedTexture = SKTexture(imageNamed: nodeType)
              }
              button.nextNodeName = nodeType
            }
          }
          spritesNode.hidden = false
          overlayNode.hidden = true
        }
      }
    }
  }
  
  var pointButtons = [PointButton]()
  var rodButtons = [SKButtonNode]()
  
  var isAddBall: Bool = false {
    didSet {
      (spritesNode.childNodeWithName("runButton") as? SKButtonNode)?.isEnabled = isAddBall && isAddDestination
    }
  }
  var isAddDestination: Bool = false {
    didSet {
      (spritesNode.childNodeWithName("runButton") as? SKButtonNode)?.isEnabled = isAddBall && isAddDestination
    }
  }
  
  var isFirstTime: Bool = true
  
  override func didMoveToView(view: SKView) {
    guard isFirstTime else { return }
    isFirstTime = false
    var pointNodes = [RotationPointNode]()
    var rods = [RodNode]()
    enumerateChildNodesWithName("//*", usingBlock: { [unowned self] (node, _) -> () in
      if let node = node as? RodNode {
        rods.append(node)
      }
      if let node = node as? RotationPointNode {
        pointNodes.append(node)
      }
      if let node = node as? SKSpriteNode where node.name == "componentButton" {
        
        let componentButton = copyNode(node, toButtonType: SKButtonNode.self, selectedTextue: nil, disabledTextue: nil)
        node.removeFromParent()
        self.spritesNode.addChild(componentButton)
        componentButton.actionTouchUpInside = { [unowned self] in
          self.spritesNode.hidden = true
          self.overlayNode.hidden = false
          self.rotatableCount = nil
          self.rotateCount = nil
          self.clockwise = nil
          self.nodeType = nil
        }
      }
      
      if let node = node as? SKSpriteNode where node.name == "runButton" {
        let runButton = copyNode(node, toButtonType: SKButtonNode.self, selectedTextue: nil, disabledTextue: nil)
        node.removeFromParent()
        self.spritesNode.addChild(runButton)
        runButton.actionTouchUpInside = self.generateNewScene
        runButton.isEnabled = false
      }
      
    })
    for rod in rods {
      let rodButton = copyNode(rod, toButtonType: SKButtonNode.self, selectedTextue: SKTexture(imageNamed: "rod0"), disabledTextue: nil)
      rodButton.name = nil
      rod.removeFromParent()
      rodButton.actionTouchUpInside = {
        let normal = rodButton.normalSKTexture
        rodButton.normalSKTexture = rodButton.selectedTexture
        rodButton.selectedTexture = normal
        if rodButton.name == nil {
          rodButton.name = "rod"
        }else {
          rodButton.name = nil
        }
      }
      spritesNode.addChild(rodButton)
      self.rodButtons.append(rodButton)
    }
    for pointNode in pointNodes {
      let pointButton = copyNode(pointNode, toButtonType: PointButton.self, selectedTextue: SKTexture(imageNamed: "pointnode0"), disabledTextue: nil) as! PointButton
      pointNode.removeFromParent()
      pointButton.type = nil
      pointButton.nextNodeName = "static"
      pointButton.actionTouchUpInside = {
//        let texture = pointButton.selectedTexture
//        pointButton.selectedTexture = pointButton.normalSKTexture
//        pointButton.normalSKTexture = texture
        if pointButton.type == nil {
          pointButton.name = pointButton.nextNodeName
          pointButton.type = PointNodeType(nodeName: pointButton.name)
          pointButton.normalSKTexture = SKTexture(imageNamed: pointButton.name!)
          pointButton.selectedTexture = SKTexture(imageNamed: "point_unchecked")
        }else {
          pointButton.type = nil
          pointButton.name = nil
          pointButton.normalSKTexture = SKTexture(imageNamed: "point_unchecked")
          pointButton.selectedTexture = SKTexture(imageNamed: pointButton.nextNodeName!)
        }

      }
      spritesNode.addChild(pointButton)
      pointButtons.append(pointButton)
    }
    spritesNode.hidden = true
    configureOverlay()
  }
  
  func configureOverlay() {
    let overlayScece = SKScene(fileNamed: "ComponentChoose")!
    addChild(overlayScece.childNodeWithName("Overlay")!.copy() as! SKNode)
    enumerateChildNodesWithName("/Overlay//*", usingBlock: { (node, _) -> () in
      if let node = node as? SKSpriteNode {
//        let button = SKButtonNode(textureNormal: node.texture, selected: SKTexture(imageNamed: "pointnode0"))
//        button.size = node.size
//        button.position = node.position
//        button.name = node.name
        let button = copyNode(node, toButtonType: SKButtonNode.self, selectedTextue: SKTexture(imageNamed: "pointnode0"), disabledTextue: nil)
        node.parent?.addChild(button)
        node.removeFromParent()
      }
    })
    
    for node in overlayNode.childNodeWithName("nodeType")!.children {
      if let node = node as? SKButtonNode {
        node.actionTouchUpInside = { [unowned self] in
          self.nodeType = node.name
        }
      }
    }
    
    
    for node in overlayNode.childNodeWithName("rotatableCount")!.children {
      if let node = node as? SKButtonNode {
        node.actionTouchUpInside = { [unowned self] in
          self.rotatableCount = node.name
        }
      }
    }
    
    for node in overlayNode.childNodeWithName("clockwise")!.children {
      if let node = node as? SKButtonNode {
        node.actionTouchUpInside = { [unowned self] in
          self.clockwise = node.name
        }
      }
    }
    
    for node in overlayNode.childNodeWithName("rotateCount")!.children {
      if let node = node as? SKButtonNode {
        node.actionTouchUpInside = { [unowned self] in
          self.rotateCount = node.name
        }
      }
    }
    
  }
  
  
  func generateNewScene() {
    let scene = LevelEditPlayScene.editScene(self.rodButtons, points: self.pointButtons, ball: self.spritesNode.childNodeWithName("ball")! as! SKSpriteNode, destination: self.spritesNode.childNodeWithName("destination")! as! SKSpriteNode)
    scene?.scaleMode = self.scaleMode
    scene?.editScene = self
    self.view?.presentScene(scene)
  }
  
  // MARK: Touch Event
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    var touchPosition = touches.first!.locationInNode(spritesNode)
    if spritesNode.nodeAtPoint(touchPosition) == spritesNode {
      if let nodeType = nodeType {
        if nodeType != "point" && nodeType != "translation" && nodeType != "static" {
          if nodeType == "ball" && isAddBall == true { return }
          if nodeType == "destination" && isAddDestination == true { return }
          let button = SKButtonNode(textureNormal: SKTexture(imageNamed: nodeType), selected: nil)
          button.position = touchPosition
          button.name = nodeType
          button.actionTouchUpInside = { [unowned self] in
            if nodeType == "ball" { self.isAddBall = false }
            if nodeType == "destination" { self.isAddDestination = false }
            button.removeFromParent()
          }
          spritesNode.addChild(button)
          if nodeType == "ball" { isAddBall = true }
          if nodeType == "destination" { isAddDestination = true }
        }
      }
    }
    touchPosition = touches.first!.locationInNode(overlayNode)
    if overlayNode.nodeAtPoint(touchPosition) == overlayNode && overlayNode.hidden == false {
      for button in pointButtons {
        let rotatableCount = self.rotatableCount == nil ? "" : self.rotatableCount!
        let clockwise = self.clockwise == nil ? "normal" : self.clockwise!
        let rotateCount = self.rotateCount == nil ? "" : self.rotateCount!
        if button.type == nil {
          button.selectedTexture = SKTexture(imageNamed: rotatableCount + clockwise + rotateCount)
        }
        button.nextNodeName = rotatableCount + clockwise + rotateCount
      }
      overlayNode.hidden = true
      spritesNode.hidden = false
    }
  }

}

func copyNode(node: SKSpriteNode, toButtonType ButtonType: SKButtonNode.Type, selectedTextue: SKTexture?, disabledTextue: SKTexture?) -> SKButtonNode {
  let button = ButtonType.init(textureNormal: node.texture, selected: selectedTextue, disabled: disabledTextue)
  button.size = node.size
  button.name = node.name
  button.position = node.position
  button.zRotation = node.zRotation
  return button
}
