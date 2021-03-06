//
//  ViewController.swift
//  RestAPIRequest
//
//  Created by Steven_WATREMEZ on 01/06/16.
//  Copyright © 2016 Steven_WATREMEZ. All rights reserved.
//

import UIKit
import PromiseKit
import SVProgressHUD

class HomeViewController: UIViewController {
  
  // MARK: propoerties
  private let webService = HTTPServicesClient(host: Host.Dev)

  // MARK: life cycle funcs
  override func viewDidLoad() {
    super.viewDidLoad()
    //launchChannelRequest()
    getChannelInfo()
    //getChannelLastVideos()
  }
  
  // MARK: private funcs
  private func launchChannelRequest() {
    SVProgressHUD.show()
    webService.fetchChannels().then { channels -> Void in
      print("Successful :)")
      print(channels)
    }.always {
      SVProgressHUD.dismiss()
      print("always goes here !")
      }.error { error in
        print("errrrrrrorororororororororo !")
        print(error)
    }
  }
  
  private func getChannelInfo() {
    SVProgressHUD.show()
    webService.fetchChannelInfo("UCVHFbqXqoYvEWM1Ddxl0QDg").then { channelInfo -> Void in
      print("Successful :)")
      print(channelInfo)
    }.always {
      SVProgressHUD.dismiss()
      print("Always goes here !")
      }.error { error in
        print("errrrrrorororororororororo !")
        print(error)
    }
  }
  
  private func getChannelLastVideos() {
    SVProgressHUD.show()
    webService.fetchLastVideosFromChannel("UCVHFbqXqoYvEWM1Ddxl0QDg", withSomeVideos: 4).then { channelVideos -> Void in
      print("Successful :)")
      print(channelVideos)
    }.always {
      SVProgressHUD.dismiss()
      print("Always goes here !")
    }.error { error in
      print("errrrrrorororororororororo !")
      print(error)
    }
  }
}

