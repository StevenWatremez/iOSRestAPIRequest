//
//  NSHTTPURLResponseExtension.swift
//  frisquet_ios
//
//  Created by SGprojet on 13/04/2016.
//  Copyright © 2016 SGprojet. All rights reserved.
//

import Foundation

extension NSHTTPURLResponse {

    var isSuccess: Bool { return 200...209 ~= statusCode }

    var isCreated: Bool { return statusCode == 201 }

    var isUnauthorized: Bool { return statusCode == 401 || statusCode == 403 }

    var isNoContent: Bool { return statusCode == 204 }
}
