//
//  APIRequestManager.swift
//  SeatGeek
//
//  Created by Simone Grant on 10/8/17.
//  Copyright © 2017 Simone Grant. All rights reserved.
//

import Foundation

class APIRequestManager {
    static let sharedManager = APIRequestManager()
    private init () {}
    
    func getData(APIEndpoint: String, callback: @escaping (Data?) -> Void) {
        guard let customURL = URL(string: APIEndpoint) else { return }
        let session = URLSession(configuration: .default)
        session.dataTask(with: customURL) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                print(error!)
            }
            guard let validData = data else { return }
            callback(validData)
        }.resume()
    }
}
