//
//  ServiceErrorProtocol.swift
//  frisquet_ios
//
//  Created by SGprojet on 13/04/2016.
//  Copyright © 2016 SGprojet. All rights reserved.
//

protocol ServiceError: ErrorType {

    var message: String { get }
}
