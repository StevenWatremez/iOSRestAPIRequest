//
//  ViewController.swift
//  RestAPIRequest
//
//  Created by Steven_WATREMEZ on 01/06/16.
//  Copyright © 2016 Steven_WATREMEZ. All rights reserved.
//

import UIKit
import PromiseKit

class HomeViewController: UIViewController {
  
  // MARK: propoerties
  private let webService = HTTPServicesClient(host: Host.Dev)

  // MARK: life cycle funcs
  override func viewDidLoad() {
    super.viewDidLoad()
    launchChannelRequest()
    //getChannelInfo()
  }
  
  // MARK: private funcs
  private func launchChannelRequest() {
    webService.fetchChannels().then { channels -> Void in
      print("Successful :)")
    }.always { 
      print("always goes here !")
      }.error { error in
        print("errrrrrrorororororororororo !")
        print(error)
    }
  }
  
  private func getChannelInfo() {
    webService.fetchChannelInfo("UCVHFbqXqoYvEWM1Ddxl0QDg").then { channelInfo -> Void in
      print("Successful :)")
    }.always { 
      print("Always goes here !")
      }.error { error in
        print("errrrrrorororororororororo !")
        print(error)
    }
  }
}

