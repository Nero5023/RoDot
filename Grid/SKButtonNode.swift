//
//  SKButtonNode.swift
//  Grid
//
//  Created by Nero Zuo on 16/3/18.
//  Copyright © 2016年 Nero. All rights reserved.
//

import SpriteKit
import UIKit

class SKButtonNode: SKSpriteNode {
  
  typealias TouchMethod = ()-> ()
  
  // MARK: Properties
  
  var actionTouchUpInside: TouchMethod?
  var actionTouchDown: TouchMethod?
  var actionTouchUp: TouchMethod?
  
  
  var isEnabled: Bool = true {
    didSet{
      if let _ = disabledTexture {
        self.texture = isEnabled ? normalSKTexture : disabledTexture
      }
    }
  }
  
  var isSelected: Bool = false {
    didSet {
      if let _ = selectedTexture , isEnabled && !isHighlight {
        self.texture = isSelected ? selectedTexture : normalSKTexture
      }else if isHighlight {
        self.texture = highlightTexture
      }
    }
  }
  
  var isHighlight: Bool = false {
    didSet {
      if let highlightTexture = highlightTexture {
        if isHighlight {
          self.texture = highlightTexture
        }else {
          self.texture = normalSKTexture
        }
      }
    }
  }
  
  var title: SKLabelNode
  var normalSKTexture: SKTexture?
  var selectedTexture: SKTexture?
  var disabledTexture: SKTexture?
  var highlightTexture: SKTexture?
  
  // MARK: Initializers
  
  
  required init(textureNormal normal: SKTexture?, selected: SKTexture?, disabled: SKTexture?) {
    self.title = SKLabelNode(fontNamed: "Arial")
    self.title.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
    self.title.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
    super.init(texture: normal, color: UIColor.clear, size: normal != nil ? normal!.size() : CGSize(width: 40, height: 40))
    self.normalSKTexture = normal
    self.selectedTexture = selected
    self.disabledTexture = disabled
    addChild(title)
    self.isUserInteractionEnabled = true
  }
  
  convenience init(textureNormal normal: SKTexture?, selected: SKTexture?) {
    self.init(textureNormal: normal, selected: selected, disabled: nil)
  }
  

  
  convenience init(imageNameNormal normal: String?, selected: String?, disabled: String?) {
    var textureNormal: SKTexture?, selectedTexture : SKTexture?, disabledTexture: SKTexture? = nil
    if let normal = normal {
      textureNormal = SKTexture(imageNamed: normal)
    }
    if let selected = selected {
      selectedTexture = SKTexture(imageNamed: selected)
    }
    if let disabled = disabled {
      disabledTexture = SKTexture(imageNamed: disabled)
    }
    self.init(textureNormal: textureNormal, selected: selectedTexture, disabled: disabledTexture)
  }
  
  convenience init(imageNameNormal normal: String?, selected: String?) {
    self.init(imageNameNormal: normal, selected: selected, disabled: nil)
  }


  convenience required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: TouchEvent
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let actionTouchDown = actionTouchDown , isEnabled {
      actionTouchDown()
    }
    if isEnabled {
      isSelected = true
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isEnabled else { return }
    let touchPoint = touches.first!.location(in: self.parent!)
    isSelected = self.frame.contains(touchPoint) ? true : false
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isEnabled else { return }
    let touchPoint = touches.first!.location(in: self.parent!)
    if self.frame.contains(touchPoint) {
      if let actionTouchUpInside = actionTouchUpInside {
        actionTouchUpInside()
      }
    }
    isSelected = false
    if let actionTouchUp = actionTouchUp {
      actionTouchUp()
    }
  }
  
}


