//
//  GetAppsService.swift
//  NatashaMartinez
//
//  Created by Natasha M on 2/18/17.
//  Copyright © 2017 Martinezpc. All rights reserved.
//

import Foundation
class GetAppsService : NetworkingManager {
    
    var applimit : String
    
    override func requestHeaders() -> [String:String]? {
        return nil
    }
    
    init(applimit: String ) {
        self.applimit = applimit
    }
    
    override func apiEndPoint() -> String {
        
        return (URLSEndpoints.url.applicationsLimit + "\(applimit)" + URLSEndpoints.url.jsonString)
    }
}
