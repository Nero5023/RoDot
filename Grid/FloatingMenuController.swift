//
//  FloatingMenuController.swift
//  FloatingMenue
//
//  Created by Nero Zuo on 15/9/6.
//  Copyright (c) 2015年 Nero. All rights reserved.
//

import UIKit
import Foundation


@objc protocol FloatingMenueControllerDelegate: class {
  @objc optional func floatingMenuController(_ controller: FloatingMenuController, didTapOnButton button: UIButton, atIndex index:Int)
  @objc optional func floatingMenuControllerDidCancel(_ controller: FloatingMenuController)
}


class FloatingMenuController: UIViewController {
  
  enum Direction {
    case up
    case down
    case left
    case right
    
    func offsetPoint(_ point: CGPoint, offset: CGFloat) -> CGPoint {
      switch self {
      case .up:
        return CGPoint(x: point.x, y: point.y - offset)
      case .down:
        return CGPoint(x: point.x, y: point.y + offset)
      case .left:
        return CGPoint(x: point.x - offset, y: point.y)
      case .right:
        return CGPoint(x: point.x + offset, y: point.y)
      }
    }
  }
  
  weak var delegate: FloatingMenueControllerDelegate?

  var buttonDirection = Direction.up
  var buttonPadding: CGFloat = 70
  var buttonItems = [UIButton]()
  
  var labelDirection = Direction.left
  var labelTitles = [String]()
  var buttonLabels = [UILabel]()
  
//  let fromView: UIView
  let fromPosition: CGPoint
  
  let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
  
  let closeButon = FloatingButton(image: UIImage(named: "icon-close"), backgroundColor: UIColor.flatRedColor)
  
  init(fromPosition: CGPoint) {
    self.fromPosition = fromPosition
    super.init(nibName: nil, bundle: nil)
    
    //present controller background doest disapper
    modalPresentationStyle = .overFullScreen
    
    //present effect
    modalTransitionStyle = .crossDissolve
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
//  func configureButtons() {
//    let parentController = presentingViewController!
//    let center = parentController.view.convertPoint(fromView.center, fromView: fromView.superview)
//    closeButon.center = center
//    
//    for (index, button) in enumerate(buttonItems) {
//      button.center = buttonDirection.offsetPoint(center, offset: buttonPadding * CGFloat(index + 1))
//    }
//  }
  
  func configureButtons(_ initial: Bool) {
    _ = presentingViewController!
//    let center = parentController.view.convertPoint(fromView.center, fromView: fromView.superview)
    let center = fromPosition
    closeButon.center = center
    
    if initial {
      closeButon.alpha = 0
      closeButon.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
      for (_, button) in buttonItems.enumerated() {
        button.center = center
        button.alpha = 0
        button.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        
      }
      
      for (index, label) in buttonLabels.enumerated() {
        let buttonCenter = buttonDirection.offsetPoint(center, offset: buttonPadding * CGFloat(index + 1))
        let labelSize = labelDirection == .up || labelDirection == .down ? label.bounds.height : label.bounds.width
        let labelCenter = labelDirection.offsetPoint(buttonCenter, offset: buttonPadding/2.0 + labelSize)
        label.center = labelCenter
        label.alpha = 0
      }
    }else {
      closeButon.alpha = 1
      closeButon.transform = CGAffineTransform.identity
      
      for (index, button) in buttonItems.enumerated() {
        button.center = buttonDirection.offsetPoint(center, offset: buttonPadding * CGFloat(index + 1))
        button.alpha = 1
        button.transform = CGAffineTransform.identity
      }
      
      for (index, label) in buttonLabels.enumerated() {
        let buttonCenter = buttonDirection.offsetPoint(center, offset: buttonPadding * CGFloat(index + 1))
        let labelSize = labelDirection == .up || labelDirection == .down ? label.bounds.height : label.bounds.width
        let labelCenter = labelDirection.offsetPoint(buttonCenter, offset: buttonPadding/2.0 + labelSize/2.0)
        label.center = labelCenter
        label.alpha = 1
      }
    }
    
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    blurredView.frame = view.bounds
    view.addSubview(blurredView)
    
    closeButon.addTarget(self, action: #selector(FloatingMenuController.handleCloseMenu(_:)), for: .touchUpInside)
    view.addSubview(closeButon)
    
    for button in buttonItems {
      button.addTarget(self, action: #selector(FloatingMenuController.handleMenuButton(_:)), for: .touchUpInside)
      view.addSubview(button)
    }
    
    for title in labelTitles {
      let label = UILabel()
      label.text = title
      label.textColor = UIColor.flatBlackColor
      label.textAlignment = .center
      label.font = UIFont(name: "HelveticaNeue-Light", size: 15)
      label.backgroundColor = UIColor.flatWhiteColor
      label.sizeToFit()
      label.bounds.size.height += 8
      label.bounds.size.width += 20
      label.layer.cornerRadius = 4
      label.layer.masksToBounds = true
      view.addSubview(label)
      buttonLabels.append(label)
    }
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    animateButtons(true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    animateButtons(false)
  }
  
  
  func handleCloseMenu(_ sender: AnyObject) {
    delegate?.floatingMenuControllerDidCancel?(self)
    SKTAudio.sharedInstance().playSoundEffect("button_click_5.wav")
    dismiss(animated: true, completion: nil)
    
  }
  
  func handleMenuButton(_ sender: AnyObject) {
    if let button = sender as? UIButton {
      if let index = buttonItems.index(of: button) {
        delegate?.floatingMenuController?(self, didTapOnButton: button, atIndex: index)
      }
    }
  }
  
  func animateButtons(_ visible: Bool) {
    configureButtons(visible)
    
    UIView.animate(withDuration: 0.4 , delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
      [unowned self] in
      self.configureButtons(!visible)
    }, completion: nil)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
  }
  
}



