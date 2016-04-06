//
//  Client.swift
//  Grid
//
//  Created by Nero Zuo on 16/4/4.
//  Copyright © 2016年 Nero. All rights reserved.
//

import Foundation

class Client {
  // MARK: Properties
  
  var session = NSURLSession.sharedSession()
  
  static let sharedInstance = Client()
  
  // MARK: Initializers
  
  private init() {}
  
  var timeOutHandler:(()->())?
  
  // MARK: GET
  
  func taskForGetMethod(method: String, parameters: [String: AnyObject], completionHandler: (data: NSData)-> ()) -> NSURLSessionTask {
    let url = urlFromParmaters(parameters, withMethod: method)
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    let task = session.dataTaskWithRequest(request) { [unowned self] data, response, error in
      self.disableTimeoutHandler()
      guard error == nil else {
        dispatch_async(dispatch_get_main_queue()) {
          HUD.flash(.LabeledError(title: "Error Happened", subtitle: "Try again"), delay: 1.3)
        }
        return
      }
      guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
        dispatch_async(dispatch_get_main_queue()) {
          HUD.flash(.LabeledError(title: "Error Happened", subtitle: "Try again"), delay: 1.3)
        }
        return
      }
      completionHandler(data: data!)
    }
    task.resume()
    return task
  }

  //MARK: POST
  
  func taskForPostMethod(method: String, jsonBody: [String: AnyObject], completionHandler: (data: NSData)-> ()) -> NSURLSessionTask {
    let url = urlFromParmaters([:], withMethod: method)
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    do {
      request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
    }catch let error as NSError {
      print("NSJSONSerialization error:\(error)")
    }
    
    let task = session.dataTaskWithRequest(request) { [unowned self] data, response, error in
      self.disableTimeoutHandler()
      guard error == nil else {
        dispatch_async(dispatch_get_main_queue()) {
          HUD.flash(.LabeledError(title: "Error Happened", subtitle: "Try again"), delay: 1.3)
        }
        return
      }
      guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
        dispatch_async(dispatch_get_main_queue()) {
          HUD.flash(.LabeledError(title: "Error Happened", subtitle: "Try again"), delay: 1.3)
        }
        return
      }
      
      completionHandler(data: data!)
    }
    
    task.resume()
    return task
  }
  
  
  private func urlFromParmaters(parameters: [String: AnyObject], withMethod method: String) -> NSURL {
    let components = NSURLComponents()
    components.scheme = Client.Constants.Scheme
    components.host = Client.Constants.Host
    components.path = method
    components.queryItems = parameters.count == 0 ? nil : [NSURLQueryItem]()
    
    for (key, value) in parameters {
      components.queryItems!.append(NSURLQueryItem(name: key, value: "\(value)"))
    }
    return components.URL!
  }
  
  
  
  func delay(delay:Double, closure:()->()) {
    dispatch_after(
      dispatch_time(
        DISPATCH_TIME_NOW,
        Int64(delay * Double(NSEC_PER_SEC))
      ),
      dispatch_get_main_queue(), closure)
  }
  
  //If Need tiemout hud, should call this
  func setTimeOutDuration(delay:Double, taskToCancel: NSURLSessionTask) {
    self.timeOutHandler = {
      HUD.flash(.LabeledError(title: "Timeout", subtitle: "Try again"), delay: 1.3)
    }
    self.delay(delay) { [unowned self] in
      if let timeOutHandler = self.timeOutHandler {
        timeOutHandler()
        taskToCancel.cancel()
      }
    }
  }
  
  // In Get POST method call this
  func disableTimeoutHandler() {
    self.timeOutHandler = nil
  }
  
}