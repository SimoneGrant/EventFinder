//
//  SeatGeekTableViewController.swift
//  SeatGeek
//
//  Created by Simone Grant on 10/8/17.
//  Copyright © 2017 Simone Grant. All rights reserved.
//
//https://github.com/homeaway/iOS-Coding-Challenge
//http://platform.seatgeek.com/

import UIKit

//make tableviewcontroller conform to Favorites protocol
class SeatGeekTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, Favorites {
    
    //hold value sent from DetailView Controller
    var gotFavorited: Bool!
    
    var cellNum: Int!
    //user defaults
    let userDefault = UserDefaults.standard
    var defaultKey = "favorited"
    var indexKey = "cell"
    //save row and value for nsuserdefault
    var favorites = [Int:Bool]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    var info = [Entertainment]()
    
    //TODO: - Hide client ID
    let url = "https://api.seatgeek.com/2/events?client_id=OTE5NDU2NnwxNTA3NDM1NTU3LjY2"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDetails()
        loadData(endpoint: url)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //check for changes
        print("I am the detail key: \(userDefault.bool(forKey: "detail"))")
        gotFavorited = userDefault.bool(forKey: "detail")
        saveDefaults()
        //update the tableview
        self.tableView.reloadData()
        print(favorites)
    }
    
    func loadData(endpoint: String) {
        APIRequestManager.sharedManager.getData(APIEndpoint: endpoint) { (data) in
            if data != nil {
                if let entertainment = getInfo(data: data!) {
                    self.info = entertainment
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    //Navigation
    func setupDetails() {
        searchBar.delegate = self
        navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    //User Defaults
    func saveDefaults() {
        //save values passed from detailviewcontroller
        userDefault.set(cellNum, forKey: indexKey)
        userDefault.set(gotFavorited, forKey: defaultKey)
        //update favorites dictionary
        favorites[userDefault.integer(forKey: indexKey)] = userDefault.bool(forKey: defaultKey)
    }
    
    //    Implement function to conform to protocol
    func isItFavorited(value: Bool) {
        self.gotFavorited = value
    }
    
    //Search Bar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        let keyword = searchBar.text
        let finalKeywords = keyword?.replacingOccurrences(of: " ", with: "+")
        //TODO:  - Refactor newURL
        let newUrl = "https://api.seatgeek.com/2/events?client_id=OTE5NDU2NnwxNTA3NDM1NTU3LjY2&q=\(finalKeywords!)"
        loadData(endpoint: newUrl)
        print(newUrl)
        self.view.endEditing(true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        
        // Remove focus from the search bar.
        searchBar.endEditing(true)
        //load original view
        loadData(endpoint: url)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        //do something
        searchBar(searchBar, textDidChange: searchBar.text!)
    }
    
    //reload searchbar on search - https://stackoverflow.com/questions/24330056/how-to-throttle-search-based-on-typing-speed-in-ios-uisearchbar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // to limit network activity, reload half a second after last key press.
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload), object: nil)
        self.perform(#selector(self.reload), with: nil, afterDelay: 0.5)
    }
    func reload() {
//        print("Doing things")
        let keyword = searchBar.text
        let finalKeywords = keyword?.replacingOccurrences(of: " ", with: "+")
        //TODO:  - Refactor newURL
        let newUrl = "https://api.seatgeek.com/2/events?client_id=OTE5NDU2NnwxNTA3NDM1NTU3LjY2&q=\(finalKeywords!)"
        loadData(endpoint: newUrl)
        print(newUrl)

    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return info.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SeatGeekTableViewCell
        
        let details = info[indexPath.row]
        let customCell = cell
        customCell.headlines = details
//        cell.titleLabel.text = "\(details.title)"
//        cell.locationLabel.text = "\(details.displayLocation)"
        
//        //date
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//        if let date = dateFormatter.date(from: details.createdAt) {
//            cell.descriptionLabel.text = "\(date)"
//        }
        
        //get images
        APIRequestManager.sharedManager.getData(APIEndpoint: details.image) { (data) in
            if let validData = data,
                let validImage = UIImage(data: validData) {
                DispatchQueue.main.async {
                    cell.eventImage.image = validImage
                    cell.setNeedsLayout()
                }
            }
        }
        let favorite = favorites[indexPath.row]
        if favorite == true {
            cell.savedFavorite.image = UIImage(named: "small_red")
        } else {
            cell.savedFavorite.image = nil
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //identify the row selected
        cellNum = indexPath.row
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //Use this instead of didselect (no navigation can be done from a cell)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedCell = sender as? UITableViewCell {
            if segue.identifier == "detailSegue" {
                let details = segue.destination as! DetailViewController
                let cellPath = self.tableView.indexPath(for: selectedCell)
                let stats = info[(cellPath?.row)!]
                //setting the custom delegate reference to this view controller
                details.pageDelegate = self
                details.linkDetails = stats
                //retain the saved favorites using the favorites array
                if favorites[(cellPath?.row)!] == true {
                    details.isFavorited = true
                } else {
                    details.isFavorited = false
                }
            }
        }
    }
}
