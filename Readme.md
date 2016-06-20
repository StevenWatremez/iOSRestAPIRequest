#Rest API Request startup architecture

- SVProgress -- Configuration is inside AppDelegate, you can define parameters here with [SVProgress doc](https://github.com/SVProgressHUD/SVProgressHUD)
- PromiseKit -- For this repo I use this Pod instead of RXSwift. Later I will create a repo with RXSwift for API Request. [PromiseKit doc](https://github.com/mxcl/PromiseKit)
- ObjectMapper -- [ObjectMapper doc](https://github.com/Hearst-DD/ObjectMapper)
- SwitGen -- you can find init in Proj/BuildPhases/SwiftGen. If you want to update this script, show [swiftgen doc](https://github.com/AliSoftware/SwiftGen/blob/master/templates/strings-default.stencil)

Localizable.strings -- to init [internationalization](http://www.ibabbleon.com/iphone_app_localization.html)
