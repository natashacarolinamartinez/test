//
//  NetworkingManager.swift
//  NatashaMartinez
//
//  Created by Natasha M on 02/18/16.
//  Copyright © 2016 Martinezpc. All rights reserved.
//

import Foundation
import Alamofire

class NetworkingManager : NSObject {

    func getMainService(completion: @escaping ((_ retrieveData: NSDictionary?, _ error: NSError?, _ errorNonJson:NSError? ) -> Void)){
        var header = requestHeaders()
        if requestHeaders() != nil {
            header = requestHeaders()!
        }
        print("the url: \(URLSEndpoints.principal + apiEndPoint()!)")
        Alamofire.request(URLSEndpoints.principal + apiEndPoint()!, method: .get, parameters: nil, encoding: URLEncoding.default, headers: header).responseJSON {
            responseObject in switch responseObject.result {
            
        case .success(let JSONObject):
            
            if responseObject.response?.statusCode == 200
            {
//                print("The jsonObject as json: \(JSONObject as! NSDictionary)")
                completion((JSONObject as! NSDictionary), nil, nil)
            }
        case .failure(let error):
           print("Request failed with error: \(error)")
           completion(nil, error as NSError?, nil)
            }
        }
    }
    /*
     (completion: ((retrieveData: NSArray?, error: NSError?, errorNonJson:NSError! ) -> Void)){
     print(kAPIBaseURL + kAPIURLTestEndPointBase + apiEndPoint()!)
     Alamofire.request(.GET, kAPIBaseURL + kAPIURLTestEndPointBase + apiEndPoint()!,
     parameters: nil,
     encoding: .URL,
     headers: requestHeaders())
     .responseJSON { responseObject in switch responseObject.result {
     
     case .Success(let JSONObject):
     
     print("Success with JSON: \(JSONObject)")
     
     if responseObject.response?.statusCode == 200
     {
     let jsonArrayData = JSONObject["data"] as! NSArray
     
     completion(retrieveData: jsonArrayData, error: nil, errorNonJson: nil)
     }
     else if responseObject.response?.statusCode == 422
     {
     let error = NSError(domain: "com." + (JSONObject["error"] as! String), code: 422, userInfo: ["errorMessage":JSONObject["message"]!!])
     completion(retrieveData: nil, error: error, errorNonJson: nil)
     }
     
     case .Failure(let error):
     
     print("Request failed with error: \(error)")
     completion(retrieveData: nil, error: error, errorNonJson: nil)
     }
     }
     */
    
    func body() -> String {
        assert(false, "Method to be implemented by subclasses")
        return ""
    }
    
    func parameters() -> [String: AnyObject]? {
        
        assert(false, "Method to be implemented by subclasses")
        return nil
    }
    
    func requestHeaders() -> [String:String]? {
        
        assert(false, "Method to be implemented by subclasses")
        return nil
    }
    
    func apiEndPoint() -> String? {
        
        assert(false, "Method to be implemented by subclasses")
        return nil
    }
    
}
extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}
