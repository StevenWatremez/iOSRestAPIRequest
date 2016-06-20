// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import UIKit

enum ImageName: String {
case Wallpaper_ocean = "wallpaper_ocean"

var image: UIImage {
  return UIImage(asset: self)
  }
}

extension UIImage {


convenience init!(asset: ImageName) {
  self.init(named: asset.rawValue)
  }
}
