//
//  HTTPServicesClient.swift
//  frisquet_ios
//
//  Created by SGprojet on 12/04/2016.
//  Copyright © 2016 SGprojet. All rights reserved.
//

import PromiseKit
import ObjectMapper

enum Host: String {

    case Dev = "frisquet-connect.cordonweb.com"
}

enum Error: ServiceError {

    case ParsingError(request: NSURLRequest, jsonResponse: AnyObject?)

    var message: String {

        var message: String

        switch self {
        case .ParsingError(let request, let jsonResponse):

            if let unwrappedJsonResponse = jsonResponse {

                message = "Invalid json response \(unwrappedJsonResponse) for request \(request)"
            } else {

                message = "Invalid empty json reponse for request \(request)"
            }
        }

        return message
    }
}

struct HTTPServicesClient {

    // MARK: Properties

    let scheme = "https"
    let host: Host
    let servicesPath = "api/v1"

    var token: String?
    var cache: VolatileCache?

    private let stack = HTTPServiceStack()

    init(host: Host) {

        self.host = host
    }
    
    // MARK: Public funcs

    func checkBoilerInfoWithIdentifier(identifier: String, agi: String) -> Promise<Void> {

        let serviceRequest = HTTPServiceRequest(verb: .Get,
                                                path: "sites/agi/\(agi)/\(identifier)")
        let URLRequest = URLRequestWithServiceRequest(serviceRequest)

        return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) throws -> Void in return }
    }

    func checkSigmacomWithKey(key: String) -> Promise<Void> {

        let serviceRequest = HTTPServiceRequest(verb: .Get,
                                                path: "sites/sigmacom/\(key)")
        let URLRequest = URLRequestWithServiceRequest(serviceRequest)

        return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) throws -> Void in return }
    }


    func createSiteWithData(siteData: SiteCreationInputData) -> Promise<Void> {

        let bodyParameters = siteData.toJSONString()

        let serviceRequest = HTTPServiceRequest(verb: .Post,
                                                path: "sites",
                                                queryParameters: nil,
                                                bodyParameters: bodyParameters?.dataUsingEncoding(NSUTF8StringEncoding))
        let URLRequest = URLRequestWithServiceRequest(serviceRequest)

        return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) throws -> Void in return }
    }

    func signInWithEmail(email: String, password: String) -> Promise<AuthenticatedUser> {

        let bodyParameters: [NSString: AnyObject] = ["email": email,
                                                     "password": password,
                                                     "client": "IOS"]

        let serviceRequest = HTTPServiceRequest(verb: .Post,
                                                path: "authentifications",
                                                queryParameters: nil,
                                                bodyParameters: bodyParameters.jsonData)
        let URLRequest = URLRequestWithServiceRequest(serviceRequest)

        return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) throws -> AuthenticatedUser in

            guard let checkedJson = json as? JSONDict,
                let authUser = Mapper<AuthenticatedUser>().map(checkedJson) else {
                    throw Error.ParsingError(request: URLRequest, jsonResponse: json)
            }

            return authUser
        }
    }

    func signUpWithEmail(email: String, password: String) -> Promise<Void> {

        let bodyParameters: [NSString: AnyObject] = ["email": email,
                                                     "plainPassword": password]

        let serviceRequest = HTTPServiceRequest(verb: .Post,
                                                path: "utilisateurs",
                                                queryParameters: nil,
                                                bodyParameters: bodyParameters.jsonData)
        let URLRequest = URLRequestWithServiceRequest(serviceRequest)

        return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) throws -> Void in return }
    }

    func fetchUserWithEmail(email: String) -> Promise<User> {

        let serviceRequest = HTTPServiceRequest(verb: .Get, path: "utilisateurs/\(email)")
        let URLRequest = URLRequestWithServiceRequest(serviceRequest)

        return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) throws -> User in

            guard let checkedJson = json as? JSONDict,
                let user = Mapper<User>().map(checkedJson) else {
                    throw Error.ParsingError(request: URLRequest, jsonResponse: json)
            }

            return user
        }
    }

    func resetPasswordWithEmail(email: String) -> Promise<Void> {

        let serviceRequest = HTTPServiceRequest(verb: .Patch, path: "utilisateurs/\(email)/forgotten_password")
        let URLRequest = URLRequestWithServiceRequest(serviceRequest)

        return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) -> Void in return }
    }

    func updateUser(user: User) -> Promise<Void> {

        let bodyParameters = user.toJSONString()

        let serviceRequest = HTTPServiceRequest(verb: .Patch,
                                                path: "utilisateurs/\(user.email)",
                                                queryParameters: nil,
                                                bodyParameters: bodyParameters?.dataUsingEncoding(NSUTF8StringEncoding),
                                                token: token!)
        let URLRequest = URLRequestWithServiceRequest(serviceRequest)

        return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) throws -> Void in

            self.cache?.patchUser(user)

            return
        }
    }

    func fetchSiteWithIdentifier(identifier: String) -> Promise<Site> {

        let serviceRequest = HTTPServiceRequest(verb: .Get, path: "sites/\(identifier)", token: token!)
        let URLRequest = URLRequestWithServiceRequest(serviceRequest)

        return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) throws -> Site in

            guard let checkedJson = json as? JSONDict,
                let site = Mapper<Site>().map(checkedJson) else {
                    throw Error.ParsingError(request: URLRequest, jsonResponse: json)
            }

            self.cache?.updateSite(site)

            return site
        }
    }

    func updateSite(site: Site) -> Promise<Void> {

        let bodyParameters = site.toJSONString()

        let serviceRequest = HTTPServiceRequest(verb: .Patch,
                                                path: "sites/\(site.boilerIdentifier)",
                                                queryParameters: nil,
                                                bodyParameters: bodyParameters?.dataUsingEncoding(NSUTF8StringEncoding),
                                                token: token!)
        let URLRequest = URLRequestWithServiceRequest(serviceRequest)

        return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) -> Void in

            self.cache?.patchSite(site)

            return
        }
    }

    func fetchZoneWithNumber(number: UInt, fromSite siteIdentifier: String) -> Promise<Zone> {

        let serviceRequest = HTTPServiceRequest(verb: .Get, path: "sites/\(siteIdentifier)/zones/\(number)", token: token!)
        let URLRequest = URLRequestWithServiceRequest(serviceRequest)

        return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) throws -> Zone in

            guard let checkedJson = json as? JSONDict,
                let zone = Mapper<Zone>().map(checkedJson) else {
                    throw Error.ParsingError(request: URLRequest, jsonResponse: json)
            }

            return zone
        }
    }

    func fetchConsumptionFromSite(siteIdentifier: String) -> Promise<Consumptions> {

        let serviceRequest = HTTPServiceRequest(verb: .Get,
                                                path: "sites/\(siteIdentifier)/conso",
                                                queryParameters: nil,
                                                queryListParameters: ["types[]": ["CHF", "SAN"]],
                                                bodyParameters: nil,
                                                token: token!)
        let URLRequest = URLRequestWithServiceRequest(serviceRequest)

        return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) throws -> Consumptions in

            guard let checkedJson = json as? JSONDict,
                let consumptions = Mapper<Consumptions>().map(checkedJson) else {
                    throw Error.ParsingError(request: URLRequest, jsonResponse: json)
            }

            return consumptions
        }
    }
    
    func sendOrder(order: Order, onSite siteIdentifier: String) -> Promise<Void> {
        
        return sendOrders([order], onSite: siteIdentifier)
    }
    
    func sendOrders(orders: [Order], onSite siteIdentifier: String) -> Promise<Void> {
        
        let bodyParameters = orders.toJSONString()
        
        let serviceRequest = HTTPServiceRequest(verb: .Post,
                                                path: "ordres/\(siteIdentifier)",
                                                queryParameters: nil,
                                                bodyParameters: bodyParameters?.dataUsingEncoding(NSUTF8StringEncoding),
                                                token: token!)
        let URLRequest = URLRequestWithServiceRequest(serviceRequest)
        
        return stack.sendRequest(URLRequest).thenInBackground { (json: AnyObject?) -> Void in return }
    }
    
    // MARK: Private funcs
    
    private func URLRequestWithServiceRequest(request: HTTPServiceRequest) -> NSURLRequest {
        
        return request.URLRequest(scheme, host: host.rawValue, servicesPath: servicesPath)
    }
}
