//
//  Entertainment.swift
//  SeatGeek
//
//  Created by Simone Grant on 10/8/17.
//  Copyright © 2017 Simone Grant. All rights reserved.
//

import Foundation

struct Entertainment {
    let title: String
    let displayLocation: String
    let createdAt: String
    let image: String
    //make init optional so the initializers are failable
    init?(dictionary: [String:Any]) {
        guard let title = dictionary["title"] as? String,
            let createdAt = dictionary["datetime_utc"] as? String else { return nil }
        guard let venue = dictionary["venue"] as? [String:Any],
            let displayLocation = venue["display_location"] as? String else { return nil }
        var image = ""
        guard let performers = dictionary["performers"] as? [[String:Any]] else { return nil }
        for details in performers {
            guard let newImage = details["image"] as? String else { return nil }
            image = newImage //?? default image
        }
        self.title = title
        self.displayLocation = displayLocation
        self.createdAt = createdAt
        self.image = image
    }
}

func getInfo(data: Data) -> [Entertainment]? {
    var info = [Entertainment]()
    do {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let validJSON = json as? [String:Any] else { return nil }
        guard let events = validJSON["events"] as? [[String: Any]] else { return nil }
        for show in events {
            if let fullDict = Entertainment(dictionary: show) {
                info.append(fullDict)
            }
        }
    } catch {
        print(error)
    }
//    print(info)
    return info
}
