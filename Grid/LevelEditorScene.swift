//
//  LevelEditorScene.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/18.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import GameplayKit

enum LayerType: String {
  case nodeTypeLayer = "nodeType"
  case rotatableCountLayer = "rotatableCount"
  case clockwiseLayer = "clockwise"
  case rotateCountLayer = "rotateCount"
  
  static var allType: [LayerType] {
    return [.nodeTypeLayer, .rotatableCountLayer, .clockwiseLayer, .rotateCountLayer]
  }
}

class LevelEditorScene: SKScene, SceneLayerProtocol {
  
  // MARK: Properties
  
  var typeLayerInfo = [LayerType: String]() {
    didSet {
      if let nodeType = typeLayerInfo[.nodeTypeLayer] {
        if nodeType != "point" {
          typeLayerInfo[.rotateCountLayer] = nil
          typeLayerInfo[.rotatableCountLayer] = nil
          typeLayerInfo[.clockwiseLayer] = nil
          if nodeType == "static" || nodeType == "translation"{
            for button in pointButtons {
              if button.type == nil {
                button.selectedTexture = SKTexture(imageNamed: nodeType)
              }
              button.nextNodeName = nodeType
            }
          }
          showEditLayer()
        }else {
          // select the point node
          showPointDetailComponent()
          hiddenOtherNodeType()
        }
      }
    }
  }
  
  var pointButtons = [PointButton]()
  var rodButtons = [SKButtonNode]()
  
  var transferNodes = Set<SKSpriteNode>() {
    didSet {
      let componentButton = spritesNode.childNodeWithName("componentButton") as! SKButtonNode
      componentButton.isEnabled = transferNodes.count % 2 == 0
      if transferNodes.count % 2 != 0 {
        (spritesNode.childNodeWithName("runButton") as? SKButtonNode)?.isEnabled = false
      }else {
        (spritesNode.childNodeWithName("runButton") as? SKButtonNode)?.isEnabled = isAddBall && isAddDestination
      }
//      for nodeName in transferNodesNames {
//        if GameplayConfiguration.transferTargetNames[nodeName] == nil {
//          componentButton.isEnabled = false
//          return
//        }
//      }
//      componentButton.isEnabled = true
    }
  }
  
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
  
  // This property is for EditButton, to prevent execute didMoveToView twice
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
        
        let componentButton = copyNode(node, toButtonType: SKButtonNode.self, selectedTextue: nil, disabledTextue: SKTexture(imageNamed: "componentButton_disabled"))
        node.removeFromParent()
        self.spritesNode.addChild(componentButton)
        
        // ComponentButton Action
        
        componentButton.actionTouchUpInside = { [unowned self] in

          self.typeLayerInfo[.rotatableCountLayer] = nil
          self.typeLayerInfo[.rotateCountLayer] = nil
          self.typeLayerInfo[.clockwiseLayer] = nil
          self.typeLayerInfo[.nodeTypeLayer] = nil
          
          self.setAllButtonsNotHighlight()
          self.showComponetLayer()
          
        }
      }
      
      if let node = node as? SKSpriteNode where node.name == "runButton" {
        let runButton = copyNode(node, toButtonType: SKButtonNode.self, selectedTextue: nil, disabledTextue: SKTexture(imageNamed: "runButton_disabled"))
        node.removeFromParent()
        self.spritesNode.addChild(runButton)
        runButton.actionTouchUpInside = self.generateNewScene
        runButton.isEnabled = false
      }
      
    })
 
    rodButtons = rods.map{ rod in
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
      return rodButton
    }
    
    pointButtons = pointNodes.map { pointNode in
      let pointButton = copyNode(pointNode, toButtonType: PointButton.self, selectedTextue: SKTexture(imageNamed: "pointnode0"), disabledTextue: nil) as! PointButton
      pointNode.removeFromParent()
      pointButton.type = nil
      pointButton.nextNodeName = "static"
      pointButton.actionTouchUpInside = {
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
      return pointButton
    }
    
//    spritesNode.hidden = true
    configureOverlay()
    
    showComponetLayer()
  }
  
  func configureOverlay() {
    let overlayScece = SKScene(fileNamed: "ComponentChoose")!
    addChild(overlayScece.childNodeWithName("Overlay")!.copy() as! SKNode)
    enumerateChildNodesWithName("/Overlay//*", usingBlock: { (node, _) -> () in
      if let node = node as? SKSpriteNode {
        let button = copyNode(node, toButtonType: SKButtonNode.self, selectedTextue: SKTexture(imageNamed: "pointnode0"), disabledTextue: nil)
        node.parent?.addChild(button)
        node.removeFromParent()
      }
    })

    setupAllButtons()
  }
  
  
  func setupAllButtons() {
    for layer in LayerType.allType {
      setUpButtonsInLayer(layer)
    }
  }
  
  
  func setUpButtonsInLayer(layer: LayerType) {
    for node in overlayNode.childNodeWithName(layer.rawValue)!.children {
      if let node = node as? SKButtonNode {
        
        // set the highlightTextue other way
        node.highlightTexture = SKTexture(imageNamed: "pointnode0")
        node.actionTouchUpInside = { [unowned self] in
          self.typeLayerInfo[layer] = node.name
          node.isHighlight = !node.isHighlight

          if node.name == "point" {
            if node.isHighlight == false {
              self.hiddenPointDetailComponent()
              self.showOtherNodeType()
            }
          }
          
          for otherNode in self.overlayNode.childNodeWithName(layer.rawValue)!.children {
            if otherNode != node {
              (otherNode as? SKButtonNode)?.isHighlight = false
            }
          }
        }
      }
    }
  }
  
  func setAllButtonsNotHighlight() {
    for layer in LayerType.allType {
      for node in overlayNode.childNodeWithName(layer.rawValue)!.children {
        if let node = node as? SKButtonNode {
          node.isHighlight = false
        }
      }
    }
  }
  
  
  func generateNewScene() {
    let scene = LevelEditPlayScene.editScene(self.rodButtons, points: self.pointButtons, ball: self.spritesNode.childNodeWithName("ball")! as! SKSpriteNode, destination: self.spritesNode.childNodeWithName("destination")! as! SKSpriteNode, transfers: [SKSpriteNode](transferNodes))
    scene?.scaleMode = self.scaleMode
    scene?.editScene = self
    self.view?.presentScene(scene)
  }
  
  
  // MARK: Help Methods
  
  func showComponetLayer() {
    self.spritesNode.hidden = true
    self.overlayNode.hidden = false
    hiddenPointDetailComponent()
    showOtherNodeType()
  }
  
  func showEditLayer() {
    self.spritesNode.hidden = false
    self.overlayNode.hidden = true
  }
  
  func showPointDetailComponent() {
    setHiddenForPointDetailComponent(false)
  }
  
  func hiddenPointDetailComponent() {
    setHiddenForPointDetailComponent(true)
  }
  
  func setHiddenForPointDetailComponent(isHidden: Bool) {
    for layerType in LayerType.allType where layerType != .nodeTypeLayer {
      overlayNode.childNodeWithName(layerType.rawValue)?.hidden = isHidden
    }
  }
  
  func hiddenOtherNodeType() {
    for node in overlayNode.childNodeWithName(LayerType.nodeTypeLayer.rawValue)!.children where node.name != "point" && node is SKButtonNode{
      node.hidden = true
    }
  }
  
  func showOtherNodeType() {
    for node in overlayNode.childNodeWithName(LayerType.nodeTypeLayer.rawValue)!.children where node.name != "point" && node is SKButtonNode{
      node.hidden = false
    }
  }
  
  
  // MARK: Touch Event
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    // In spritesNode action
    var touchPosition = touches.first!.locationInNode(spritesNode)
    if spritesNode.nodeAtPoint(touchPosition) == spritesNode && overlayNode.hidden == true {
      if let nodeType = typeLayerInfo[.nodeTypeLayer] {
        // Make sure it's not the point node
        if nodeType == "ball" || nodeType == "destination" {
          
          if nodeType == "ball" && isAddBall == true { return }
          if nodeType == "destination" && isAddDestination == true { return }
          
          let button = SKButtonNode(textureNormal: SKTexture(imageNamed: nodeType), selected: nil)
          button.position = touchPosition
          button.name = nodeType
          // Ball or destination action
          button.actionTouchUpInside = { [unowned self] in
            if nodeType == "ball" { self.isAddBall = false }
            if nodeType == "destination" { self.isAddDestination = false }
            button.removeFromParent()
          }
          spritesNode.addChild(button)
          if nodeType == "ball" { isAddBall = true }
          if nodeType == "destination" { isAddDestination = true }
        }
        if nodeType == "transfer" {
          addTransfer(touchPosition)
        }
      }
    }
    // In overlayNode action
    touchPosition = touches.first!.locationInNode(overlayNode)
    if overlayNode.nodeAtPoint(touchPosition) == overlayNode && overlayNode.hidden == false {
      for button in pointButtons {
        let rotatableCount = self.typeLayerInfo[.rotatableCountLayer] == nil ? "" : self.typeLayerInfo[.rotatableCountLayer]!
        let clockwise = self.typeLayerInfo[.clockwiseLayer] == nil ? "normal" : self.typeLayerInfo[.clockwiseLayer]!
        let rotateCount = self.typeLayerInfo[.rotateCountLayer] == nil ? "" : self.typeLayerInfo[.rotateCountLayer]!
        if button.type == nil {
          button.selectedTexture = SKTexture(imageNamed: rotatableCount + clockwise + rotateCount)
        }
        button.nextNodeName = rotatableCount + clockwise + rotateCount
      }
      showEditLayer()
    }
  }
  
  func addTransfer(touchPosition: CGPoint) {
    let nodeType = "transfer"
    if transferNodes.count == 2 {
      return
    }
    let button = SKButtonNode(textureNormal: SKTexture(imageNamed: nodeType), selected: nil)
    button.position = touchPosition
    if transferNodes.count == 0 {
      button.name = nodeType + String(transferNodes.count)
    }else if transferNodes.count == 1 {
      button.name = GameplayConfiguration.transferTargetNames[transferNodes.first!.name!]
    }
    transferNodes.insert(button)
    button.actionTouchUp = { [unowned self] in
      button.removeFromParent()
      self.typeLayerInfo[.nodeTypeLayer] = nodeType
      self.transferNodes.remove(button)
    }
    spritesNode.addChild(button)
  }

}



// MARK: Help function
func copyNode(node: SKSpriteNode, toButtonType ButtonType: SKButtonNode.Type, selectedTextue: SKTexture?, disabledTextue: SKTexture?) -> SKButtonNode {
  let button = ButtonType.init(textureNormal: node.texture, selected: selectedTextue, disabled: disabledTextue)
  button.size = node.size
  button.name = node.name
  button.position = node.position
  button.zRotation = node.zRotation
  return button
}
