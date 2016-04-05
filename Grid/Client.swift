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
  
  // MARK: GET
  
  func taskForGetMethod(method: String, parameters: [String: AnyObject], completionHandler: (data: NSData)-> ()) -> NSURLSessionTask {
    let url = urlFromParmaters(parameters, withMethod: method)
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    let task = session.dataTaskWithRequest(request) { data, response, error in
      guard error == nil else {
        // error handler
        return
      }
      guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
        // error handler
        return
      }
      completionHandler(data: data!)
    }
    task.resume()
    return task
  }

  //MARK: POST
  
  func taskForPostMethod(method: String, parameters: [String: AnyObject], completionHandler: (data: NSData)-> ()) -> NSURLSessionTask {
    let url = urlFromParmaters([:], withMethod: method)
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    do {
      request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
    }catch let error as NSError {
      print("NSJSONSerialization error:\(error)")
    }
    
    let task = session.dataTaskWithRequest(request) { data, response, error in
      guard error == nil else {
        // error handler
        return
      }
      guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
        // error handler
        print((response as? NSHTTPURLResponse)?.statusCode)
        return
      }
      completionHandler(data: data!)
    }
    
    task.resume()
    return task
    
  }
  
  
  func urlFromParmaters(parameters: [String: AnyObject], withMethod method: String) -> NSURL {
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
  
}