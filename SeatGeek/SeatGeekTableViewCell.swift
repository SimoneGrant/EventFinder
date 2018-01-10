//
//  SeatGeekTableViewCell.swift
//  SeatGeek
//
//  Created by Simone Grant on 10/9/17.
//  Copyright © 2017 Simone Grant. All rights reserved.
//

import UIKit

class SeatGeekTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var savedFavorite: UIImageView!

    //figure out why this didn't work
    var headlines: Entertainment? {
        //didSet is a property observer
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        titleLabel.text = headlines?.title
        locationLabel.text = headlines?.displayLocation
        //date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        if let date = dateFormatter.date(from: (headlines?.createdAt)!) {
            descriptionLabel.text = "\(date)"
        }
        
    }
}
