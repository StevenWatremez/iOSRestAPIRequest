//
//  HTTPServiceStack.swift
//  frisquet_ios
//
//  Created by SGprojet on 12/04/2016.
//  Copyright © 2016 SGprojet. All rights reserved.
//

import PromiseKit
import Foundation

typealias JSONDict = [String: AnyObject]
typealias JSONArray = [JSONDict]

let unauthorizedUserNotification = "UnauthorizedUserNotification"

struct HTTPServiceStack {

  enum Error: ServiceError {
    case InternalError
    case NetworkError(error: ErrorType)
    case HTTPError(statusCode: Int, jsonError: JSONDict?)
    
    var message: String {
      var message = "Default error message"
      switch self {
      case .HTTPError(_, let jsonError):
        
        if let jsonDict = jsonError,
          let jsonMessage = jsonDict["message"] as? String {
          
          message = jsonMessage
        }
      case .NetworkError(let error):
        let innerError = error as NSError
        if let localizedFailureReason = innerError.localizedFailureReason where !localizedFailureReason.isEmpty {
          message = localizedFailureReason
        } else {
          if !innerError.localizedDescription.isEmpty {
            message = innerError.localizedDescription
          }
        }
      default: break
      }
      return message
    }
  }
  
  // MARK: Properties
  private let session = NSURLSession.sharedSession()
  
  // MARK: Public funcs
  /// Return a Promise of AnyObject?.
  /// It checks errors about HTTP and Network
  func sendRequest(request: NSURLRequest) -> Promise<AnyObject?> {
    return sendRequest(request)
      .recover { (error: ErrorType) throws -> (NSData, NSHTTPURLResponse) in
        throw Error.NetworkError(error: error)
      }.then { (data: NSData, response: NSHTTPURLResponse) throws -> NSData in
        guard response.isSuccess else {
          self.logRequest(request, data: data)
          
          if response.isUnauthorized {
            NSNotificationCenter.defaultCenter().postNotificationName(unauthorizedUserNotification, object: nil)
          }
          var jsonError: AnyObject
          
          do {
            jsonError = try NSJSONSerialization.JSONObjectWithData(data, options: [])
          } catch {
            throw Error.HTTPError(statusCode: response.statusCode, jsonError: nil)
          }
          throw Error.HTTPError(statusCode: response.statusCode, jsonError: jsonError as? JSONDict)
        }
        
        if response.isNoContent && data.length != 0 {
          print("HTTP 204 received though data is not empty !")
        } else if !response.isNoContent && data.length == 0 {
          print("Data is empty though received HTTP code is not 204 !")
        }
        return data
        
      }.then { data throws -> AnyObject? in
        
        if data.length != 0 {
          let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
          try self.logRequest(request, responseJsonObject: jsonObject)
          return jsonObject
        } else {
          self.logRequest(request)
          return nil
        }
      }
  }
  
  // MARK: Private funcs
  
  private func sendRequest(request: NSURLRequest) -> Promise<(NSData, NSHTTPURLResponse)> {
    return Promise { (fulfill, reject) throws -> Void in
      self.session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
        if let error = error { return reject(error) }
        guard let data = data, response = response as? NSHTTPURLResponse else {
          return reject(Error.InternalError)
        }
        fulfill((data, response))
        }.resume()
    }
  }
  
  private func logRequest(request: NSURLRequest) {
    print("Received empty response for request \(request)")
  }
  
  private func logRequest(request: NSURLRequest, data: NSData) {
    let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
    print("Received response for request \(request) :\n\(responseString)")
  }
  
  private func logRequest(request: NSURLRequest, responseJsonObject: AnyObject) throws {
    let prettyJsonData = try NSJSONSerialization.dataWithJSONObject(responseJsonObject, options: .PrettyPrinted)
    let prettyJsonString = NSString(data: prettyJsonData, encoding: NSUTF8StringEncoding)!
    print("Received response for request \(request) :\n\(prettyJsonString)")
  }
}
