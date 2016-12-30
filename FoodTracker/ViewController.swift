//
//  ViewController.swift
//  FoodTracker
//
//  Created by Kashish Goel on 2015-07-23.
//  Copyright (c) 2015 Kashish Goel. All rights reserved.
//



import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    
    //variables
    let kAppId = "13ecd6b9"
    let kAppKey = "2eb8fc722e1ec27acff39b259d459677"
    
    var searchController:UISearchController!
    
    var suggestedSearchFoods:[String] = []
    var filteredSuggestedSearchFoods:[String] = []
    
    var apiSearchForFoods:[(name: String, idValue: String)] = []
    
    var favoritedUSDAItems:[USDAItem] = []
    var filteredFavoritedUSDAItems:[USDAItem] = []
    
    var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
    
    var jsonResponse:NSDictionary!
    
    var dataController = DataController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        //can make true
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        self.searchController.searchBar.frame = CGRect(x: self.searchController.searchBar.frame.origin.x, y: self.searchController.searchBar.frame.origin.y, width: self.searchController.searchBar.frame.size.width, height: 44.0)
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        self.searchController.searchBar.scopeButtonTitles = scopeButtonTitles
        self.searchController.searchBar.delegate = self
        //suggested by E.A
        self.definesPresentationContext = true
        
        self.suggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicen breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.usdaItemDidComplete(_:)), name: NSNotification.Name(rawValue: kUSDAItemCompleted), object: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVCSegue" {
            if sender != nil {
                let detailVC = segue.destination as! DetailViewController
                detailVC.usdaItem = sender as? USDAItem
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Mark - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {
            if self.searchController.isActive {
                return self.filteredSuggestedSearchFoods.count
            }
            else {
                return self.suggestedSearchFoods.count
            }
        }
        else if selectedScopeButtonIndex == 1 {
            return self.apiSearchForFoods.count
        }
        else {
            if self.searchController.isActive {
                return self.filteredFavoritedUSDAItems.count
            }
            else {
                return self.favoritedUSDAItems.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")! as UITableViewCell
        
        var foodName : String
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {
            if self.searchController.isActive {
                foodName = filteredSuggestedSearchFoods[indexPath.row]
            }
            else {
                foodName = suggestedSearchFoods[indexPath.row]
            }
        }
        else if selectedScopeButtonIndex == 1 {
            foodName = apiSearchForFoods[indexPath.row].name
        }
        else {
            if self.searchController.isActive {
                foodName = self.filteredFavoritedUSDAItems[indexPath.row].name
            }
            else {
                foodName = self.favoritedUSDAItems[indexPath.row].name
            }
        }
        
        cell.textLabel?.text = foodName
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    
    // Mark - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0 {
            var searchFoodName:String
            
            if self.searchController.isActive {
                searchFoodName = filteredSuggestedSearchFoods[indexPath.row]
            }
            else {
                searchFoodName = suggestedSearchFoods[indexPath.row]
            }
            self.searchController.searchBar.selectedScopeButtonIndex = 1
            makeRequest(searchFoodName)
            
        }
        else if selectedScopeButtonIndex == 1 {
            self.performSegue(withIdentifier: "toDetailVCSegue", sender: nil)
            let idValue = apiSearchForFoods[indexPath.row].idValue
            self.dataController.saveUSDAItemForId(idValue, json: self.jsonResponse)
        }
        else if selectedScopeButtonIndex == 2 {
            if self.searchController.isActive {
                let usdaItem = filteredFavoritedUSDAItems[indexPath.row]
                self.performSegue(withIdentifier: "toDetailVCSegue", sender: usdaItem)
            }
            else {
                let usdaItem = favoritedUSDAItems[indexPath.row]
                self.performSegue(withIdentifier: "toDetailVCSegue", sender: usdaItem)
            }
        }
    }
    
    
    // UISearchResultsUpdating, updates everytime search bad is updated
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchString = self.searchController.searchBar.text
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        self.filterContentForSearch(searchString!, scope: selectedScopeButtonIndex)
        self.tableView.reloadData()
    }
    
    
    //filters
    func filterContentForSearch (_ searchText: String, scope: Int) {
        if scope == 0 {
            
            self.filteredSuggestedSearchFoods = self.suggestedSearchFoods.filter({ (food : String) -> Bool in
                let foodMatch = food.range(of: searchText)
                return foodMatch != nil
            })
        }
        else if scope == 2 {
            self.filteredFavoritedUSDAItems = self.favoritedUSDAItems.filter({ (item: USDAItem) -> Bool in
                let stringMatch = item.name.range(of: searchText)
                return stringMatch != nil
            })
        }
    }
    
    //UISearchBarDelegate, everytime search is clicked it makes the request and fetches the api info
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.searchBar.selectedScopeButtonIndex = 1
        makeRequest(searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        if selectedScope == 2 {
            requestFavoritedUSDAItems()
        }
        
        self.tableView.reloadData()
    }
    
    
    
    func makeRequest (_ searchString : String) {
        
        //How to make a HTTP Get Request
        //        let url = NSURL(string: "https://api.nutritionix.com/v1_1/search/\(searchString)?results=0%3A20&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId=\(kAppId)&appKey=\(kAppKey)")
        //        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
        //            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
        //            println(stringData)
        //            println(response)
        //        })
        //        task.resume()
        
        var request = URLRequest(url: URL(string: "https://api.nutritionix.com/v1_1/search/")!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        
        var params = [
            "appId" : kAppId,
            "appKey" : kAppKey,
            "fields" : ["item_name", "brand_name", "keywords", "usda_fields"],
            "limit"  : "50",
            "query"  : searchString,
            "filters": ["exists":["usda_fields": true]]] as [String : Any]
        
        var error: NSError?
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch var error1 as NSError {
            error = error1
            request.httpBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTask(with: request, completionHandler: { (data, response, err) -> Void in
            
            //            var stringData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //            println(stringData)
            var conversionError: NSError?
            var jsonDictionary:NSDictionary?
            do {  jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as? NSDictionary} catch {}
//            print(jsonDictionary)
            
            if conversionError != nil {
                print(conversionError!.localizedDescription)
                let errorString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("Error in Parsing \(errorString)")
            }
                
            else {
                if jsonDictionary != nil {
                    self.jsonResponse = jsonDictionary!
                    
                    self.apiSearchForFoods = DataController.jsonAsUSDAIdAndNameSearchResults(jsonDictionary!)
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.tableView.reloadData()
                    })
                }
                else {
                    let errorString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print("Error Could not Parse JSON \(errorString)")
                }
            }
        })
        task.resume()
    }
    
    //CoreData
    
    func requestFavoritedUSDAItems () {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USDAItem")
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        self.favoritedUSDAItems = (try! managedObjectContext?.fetch(fetchRequest)) as! [USDAItem]
    }
    
    
    // notif centre, see bitfountain.io 
    
    func usdaItemDidComplete(_ notification : Notification) {
        
        print("usdaItemDidComplete in ViewController")
        requestFavoritedUSDAItems()
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        if selectedScopeButtonIndex == 2 {
            self.tableView.reloadData()
        }
    }
}



