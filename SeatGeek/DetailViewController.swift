//
//  DetailViewController.swift
//  SeatGeek
//
//  Created by Simone Grant on 10/9/17.
//  Copyright © 2017 Simone Grant. All rights reserved.
//

import UIKit

//created protocol to help pass data
protocol Favorites {
    func isItFavorited(value: Bool)
}

class DetailViewController: UIViewController {
    //create delegate that conforms to the protocol
    var pageDelegate: Favorites?

    var linkDetails: Entertainment?
    var isFavorited: Bool!
    let userDefault = UserDefaults.standard
    var detailKey = "detail"
    //Outlets
    @IBOutlet weak var fullSizeImg: UIImageView!
    @IBOutlet weak var descripLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDetails()
        
        userDefault.set(isFavorited, forKey: detailKey)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //use this to read boolean value from protocol delegate
        pageDelegate?.isItFavorited(value: isFavorited)
        
        //trying to get previously true cells to remain true
        if userDefault.bool(forKey: detailKey) == true {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        }
        
         //stack overflow - https://stackoverflow.com/questions/39652807/remove-back-button-text-from-inherited-navigation-bar-swift-3
        if let viewControllers = self.navigationController?.viewControllers {
            let previousVC: UIViewController? = viewControllers.count >= 2 ? viewControllers[viewControllers.count - 2] : nil; // get previous view
            previousVC?.title = "" // or previousVC?.title = "Back"
        }
    }
        
    //if favorite is selected, set the right color
    func selectFavorite() {
        if isFavorited == false {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.red
            isFavorited = true
            pageDelegate?.isItFavorited(value: isFavorited)
        } else {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.gray
            isFavorited = false
            pageDelegate?.isItFavorited(value: isFavorited)
        }
        userDefault.set(isFavorited, forKey: detailKey)
    }
  
    //Load Image and Labels
    func loadDetails() {
        //set navigation title
        self.navigationItem.title = linkDetails?.title
        //only available in ios 11
        //        navigationController?.navigationBar.prefersLargeTitles = true
        
        //setup favorites button
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "large_dark"), style: .plain, target: self, action: #selector(selectFavorite))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.gray
        
        //get image without force unwrapping string (temp)
        if let image = linkDetails?.image {
            APIRequestManager.sharedManager.getData(APIEndpoint: image) { (data) in
                if let validData = data,
                    let validImage = UIImage(data: validData) {
                    DispatchQueue.main.async {
                        self.fullSizeImg.image = validImage
                        self.fullSizeImg.setNeedsLayout()
                    }
                }
            }
        } else {
            if let image = linkDetails?.image {
                print("image not found \(image)")
            }
        }
        //get other labels
        if let created = linkDetails?.createdAt, let location = linkDetails?.displayLocation {
            descripLabel.text = "\(created)"
            locationLabel.text = "\(location)"
        }
    }
}


