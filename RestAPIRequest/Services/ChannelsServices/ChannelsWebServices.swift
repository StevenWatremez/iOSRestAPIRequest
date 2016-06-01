//
//  ChannelsWebServices.swift
//  RestAPIRequest
//
//  Created by Steven_WATREMEZ on 01/06/16.
//  Copyright © 2016 Steven_WATREMEZ. All rights reserved.
//
import PromiseKit
import Foundation
import ObjectMapper

struct ChannelConstants {
  static let channelsRessource = "channels"
}

struct Channel: Mappable {
  var name = ""
  var youtubeId = ""
  var isTuts = false
  
  init?(_ map: Map) {}
  
  mutating func mapping(map: Map) {
    name      <- map["name"]
    youtubeId <- map["ytid"]
    isTuts    <- map["isTuts"]
  }
}

struct ChannelInfo: Mappable {
  var etag = ""
  
  init?(_ map: Map) {}
  
  mutating func mapping(map: Map) {
    etag      <- map["etag"]
  }
}

struct ChannelVideo: Mappable {
  var etag = ""
  
  init?(_ map: Map) {}
  
  mutating func mapping(map: Map) {
    etag      <- map["etag"]
  }
}

extension HTTPServicesClient {
  
  func fetchChannels() -> Promise<Array<Channel>> {
    let serviceRequest = HTTPServiceRequest(verb: .Get, path: "\(ChannelConstants.channelsRessource)")
    let URLRequest = URLRequestWithServiceRequest(serviceRequest)
    
    return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) throws -> Array<Channel> in
      guard let checkedJson = json as? JSONArray,
        let channels = Mapper<Channel>().mapArray(checkedJson) else {
          throw Error.ParsingError(request: URLRequest, jsonResponse: json)
      }
      return channels
    }
  }
  
  func fetchChannelInfo(identifier: String) -> Promise<ChannelInfo> {
    let serviceRequest = HTTPServiceRequest(verb: .Get, path: "\(ChannelConstants.channelsRessource)/\(identifier)/info")
    let URLRequest = URLRequestWithServiceRequest(serviceRequest)
    
    return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) throws -> ChannelInfo in
      guard let checkedJson = json as? JSONDict,
        let channels = Mapper<ChannelInfo>().map(checkedJson) else {
          throw Error.ParsingError(request: URLRequest, jsonResponse: json)
      }
      return channels
    }
  }
  
  func fetchLastVideosFromChannel(identifier: String, withSomeVideos numberOfVideos: Int) -> Promise<Array<ChannelVideo>> {
    let serviceRequest = HTTPServiceRequest(
      verb: .Get,
      path: "\(ChannelConstants.channelsRessource)/\(identifier)/info",
      queryParameters: ["size": "\(numberOfVideos)"],
      bodyParameters: nil)
    let URLRequest = URLRequestWithServiceRequest(serviceRequest)
    
    return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) throws -> Array<ChannelVideo> in
      guard let checkedJson = json as? JSONArray,
        let channelVideos = Mapper<ChannelVideo>().mapArray(checkedJson) else {
          throw Error.ParsingError(request: URLRequest, jsonResponse: json)
      }
      return channelVideos
    }
  }
}
