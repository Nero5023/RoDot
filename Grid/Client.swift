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
  
  var session = URLSession.shared
  
  static let sharedInstance = Client()
  
  // MARK: Initializers
  
  fileprivate init() {}
  
  var timeOutHandler:(()->())?
  
  // MARK: GET
  
  func taskForGetMethod(_ method: String, parameters: [String: AnyObject], completionHandler: @escaping (_ data: Data)-> ()) -> URLSessionTask {
    let url = urlFromParmaters(parameters, withMethod: method)
    let request = NSMutableURLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    let task = session.dataTask(with: request, completionHandler: { [unowned self] data, response, error in
      self.disableTimeoutHandler()
      guard error == nil else {
        DispatchQueue.main.async {
          if error!.localizedDescription != "cancelled" {
            HUD.flash(.labeledError(title: "Error Happened", subtitle: "Try again"), delay: 1.3)
          }
        }
        return
      }
      guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
        DispatchQueue.main.async {
          HUD.flash(.labeledError(title: "Error Happened", subtitle: "Try again"), delay: 1.3)
        }
        return
      }
      completionHandler(data: data!)
    }) 
    task.resume()
    return task
  }

  //MARK: POST
  
  func taskForPostMethod(_ method: String, jsonBody: [String: AnyObject], completionHandler: @escaping (_ data: Data)-> ()) -> URLSessionTask {
    let url = urlFromParmaters([:], withMethod: method)
    let request = NSMutableURLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
    }catch let error as NSError {
      print("NSJSONSerialization error:\(error)")
    }
    
    let task = session.dataTask(with: request, completionHandler: { [unowned self] data, response, error in
      self.disableTimeoutHandler()
      guard error == nil else {
        DispatchQueue.main.async {
          print(error?.localizedDescription)
          if error!.localizedDescription != "cancelled" {
            HUD.flash(.labeledError(title: "Error Happened", subtitle: "Try again"), delay: 1.3)
          }
        }
        return
      }
      guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
        DispatchQueue.main.async {
          print((response as? HTTPURLResponse)?.statusCode)
          HUD.flash(.labeledError(title: "Error Happened", subtitle: "Try again"), delay: 1.3)
        }
        return
      }
      
      completionHandler(data: data!)
    }) 
    
    task.resume()
    return task
  }
  
  
  fileprivate func urlFromParmaters(_ parameters: [String: AnyObject], withMethod method: String) -> URL {
    var components = URLComponents()
    components.scheme = Client.Constants.Scheme
    components.host = Client.Constants.Host
    components.path = method
    components.queryItems = parameters.count == 0 ? nil : [URLQueryItem]()
    
    for (key, value) in parameters {
      components.queryItems!.append(URLQueryItem(name: key, value: "\(value)"))
    }
    return components.url!
  }
  
  
  
  func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
      deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
  }
  
  //If Need tiemout hud, should call this
  func setTimeOutDuration(_ delay: Double, taskToCancel: URLSessionTask) {
    self.timeOutHandler = {
      HUD.flash(.labeledError(title: "Timeout", subtitle: "Try again"), delay: 1.3)
      SKTAudio.sharedInstance().playSoundEffect("timeout.wav")
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
