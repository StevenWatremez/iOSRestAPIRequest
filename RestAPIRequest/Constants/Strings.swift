// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation

enum L10n {
  /// Title of the alert
  case AlertTitle
  /// Some alert body there
  case AlertMessage
  /// Hello, my name is %@ and I'm %d
  case Greetings(String, Int)
  /// You have %d apples
  case ApplesCount(Int)
  /// Those %d bananas belong to %@.
  case BananasOwner(Int, String)
}

extension L10n: CustomStringConvertible {
  var description: String { return self.string }

  var string: String {
    switch self {
      case .AlertTitle:
        return L10n.tr("alert_title")
      case .AlertMessage:
        return L10n.tr("alert_message")
      case .Greetings(let p0, let p1):
        return L10n.tr("greetings", p0, p1)
      case .ApplesCount(let p0):
        return L10n.tr("apples.count", p0)
      case .BananasOwner(let p0, let p1):
        return L10n.tr("bananas.owner", p0, p1)
    }
  }

  private static func tr(key: String, _ args: CVarArgType...) -> String {
    let format = NSLocalizedString(key, comment: "")
    return String(format: format, locale: NSLocale.currentLocale(), arguments: args)
  }
}

func tr(key: L10n) -> String {
  return key.string
}
