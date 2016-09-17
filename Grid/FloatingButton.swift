//
//  FloatingButton.swift
//  FloatingMenue
//
//  Created by Nero Zuo on 15/9/6.
//  Copyright (c) 2015年 Nero. All rights reserved.
//

import UIKit

let FloatingButtonWidth: CGFloat = 50
let FloatingButtonMargin: CGFloat = 20

class FloatingButton: UIButton {
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }
  
  convenience init(image: UIImage?, backgroundColor: UIColor = UIColor.flatBlueColor) {
    self.init()
    setImage(image, for: UIControlState())
    setBackgroundImage(backgroundColor.pixelImage, for: UIControlState())
  }
  
  convenience init() {
    self.init(frame: CGRect(x: 0, y: 0, width: FloatingButtonWidth, height: FloatingButtonWidth))
  }
  
  func setup() {
    tintColor = UIColor.white
    if backgroundImage(for: UIControlState()) == nil {
      setBackgroundImage(UIColor.flatBlueColor.pixelImage , for: UIControlState())
    }
    layer.cornerRadius = frame.width/2.0
    layer.masksToBounds = true
  }
  
}

