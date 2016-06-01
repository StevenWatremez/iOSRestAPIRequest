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

struct ChannelVideo: Mappable {
  var etag = ""
  var videoId = ""
  var channelId = ""
  var channelTitle = ""
  var description = ""
  var liveBroadcastContent = ""
  var publishedAt = NSDate()
  var thumbnail = ""
  var title = ""
  
  init?(_ map: Map) {}
  
  mutating func mapping(map: Map) {
    etag                  <- map["etag"]
    videoId               <- map["id.videoId"]
    channelId             <- map["snippet.channelId"]
    channelTitle          <- map["snippet.channelTitle"]
    description           <- map["snippet.description"]
    liveBroadcastContent  <- map["snippet.liveBroadcastContent"]
    publishedAt           <- (map["snippet.publishedAt"], DateTransform())
    thumbnail             <- map["snippet.thumbnails.medium.url"]
    title                 <- map["snippet.title"]
  }
}

struct ChannelInfo: Mappable {
  var etag = ""
  var items = [ChannelItem]()
  
  init?(_ map: Map) {}
  
  mutating func mapping(map: Map) {
    etag          <- map["etag"]
    items         <- map["items"]
  }
}
struct ChannelItem: Mappable {
  var id = ""
  var title = ""
  var description = ""
  var keywords = ""
  var profileColor = ""
  var banner = ""
  var publishedAt = NSDate()
  var thumbnail  = ""
  var statistics: ChannelStatistics? = nil
  
  init?(_ map: Map) {}
  
  mutating func mapping(map: Map) {
    id            <- map["id"]
    title         <- map["snippet.title"]
    description   <- map["snippet.description"]
    keywords      <- map["brandingSettings.channel.keywords"]
    profileColor   <- map["brandingSettings.channel.profileColor"]
    banner        <- map["brandingSettings.image.bannerMobileImageUrl"]
    publishedAt   <- (map["snippet.publishedAt"], DateTransform())
    thumbnail     <- map["snippet.thumbnails.medium.url"]
    statistics    <- map["statistics"]
  }
}

struct ChannelStatistics: Mappable {
  var commentCount = ""
  var subscribeCount = ""
  var videoCount = ""
  var viewCount = ""
  
  init?(_ map: Map) {}
  
  mutating func mapping(map: Map) {
    commentCount <- map ["commentCount"]
    subscribeCount <- map ["subscribeCount"]
    videoCount <- map ["videoCount"]
    viewCount <- map ["viewCount"]
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
      path: "\(ChannelConstants.channelsRessource)/\(identifier)/lastVideos",
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
