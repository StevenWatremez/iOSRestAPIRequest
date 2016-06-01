//
//  HTTPServiceRequest.swift
//  frisquet_ios
//
//  Created by SGprojet on 12/04/2016.
//  Copyright © 2016 SGprojet. All rights reserved.
//

import Foundation

typealias ListParameters = [String: [AnyObject]]

struct HTTPServiceRequest {
  
  enum Verb: String {
    case Get = "GET"
    case Post = "POST"
    case Put = "PUT"
    case Patch = "PATCH"
    case Delete = "DELETE"
  }
  
  // MARK: Properties
  let verb: Verb
  let path: String
  let queryParameters: JSONDict?
  let queryListParameters: ListParameters?
  let bodyParameters: NSData?
  let token: String?
  
  // MARK: Life-cycle
  init(verb: Verb, path: String, queryParameters: JSONDict?, queryListParameters: ListParameters?, bodyParameters: NSData?, token: String?) {
    self.verb = verb
    self.path = path
    self.queryParameters = queryParameters
    self.queryListParameters = queryListParameters
    self.bodyParameters = bodyParameters
    self.token = token
  }
  
  init(verb: Verb, path: String, queryParameters: JSONDict?, bodyParameters: NSData?, token: String) {
    self.init(verb: verb, path: path, queryParameters: queryParameters, queryListParameters: nil, bodyParameters: bodyParameters, token: token)
  }
  
  init(verb: Verb, path: String, queryParameters: JSONDict?, bodyParameters: NSData?) {
    self.init(verb: verb, path: path, queryParameters: queryParameters, queryListParameters: nil, bodyParameters: bodyParameters, token: nil)
  }
  
  init(verb: Verb, path: String, token: String) {
    self.init(verb: verb, path: path, queryParameters: nil, queryListParameters: nil, bodyParameters: nil, token: token)
  }
  
  init(verb: Verb, path: String) {
    self.init(verb: verb, path: path, queryParameters: nil, bodyParameters: nil)
  }
  
  // MARK: Public funcs
  /// Returns NSURLRequest create with:
  ///
  /// scheme : the url scheme like "http"
  ///
  /// host : the url host like "youcode.io"
  
  /// servicesPath : the url servicesPath like "api/V2"
  func URLRequest(scheme: String, host: String) -> NSURLRequest {
    let components = NSURLComponents()
    components.scheme = scheme
    components.host = host
    components.path = "/\(path)"
    
    var queryItems: [NSURLQueryItem] = []
    
    if let unwrappedToken = token {
      queryItems.append(NSURLQueryItem(name: "token", value: unwrappedToken))
    }
    
    if let unwrappedQueryParameters = queryParameters {
      for (key, value) in unwrappedQueryParameters {
        queryItems.append(NSURLQueryItem(name: key, value: value.description))
      }
    }
    
    if let unwrappedQueryListParameters = queryListParameters {
      for (key, values) in unwrappedQueryListParameters {
        for value in values {
          queryItems.append(NSURLQueryItem(name: key, value: value.description))
        }
      }
    }
    components.queryItems = queryItems
    
    let request = NSMutableURLRequest(URL: components.URL!)
    request.HTTPMethod = verb.rawValue
    
    if let unwrappedBodyParameters = bodyParameters {
      request.HTTPBody = unwrappedBodyParameters
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    return request
  }
}
