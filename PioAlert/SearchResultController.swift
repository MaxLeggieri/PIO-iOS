//
//  SearchResultController.swift
//  PioAlert
//
//  Created by LiveLife on 11/05/2017.
//  Copyright © 2017 LiveLife. All rights reserved.
//

import UIKit

class SearchResultController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView:UITableView!
    //@IBOutlet var searchBar:UISearchBar!
    
    var data = [[String:AnyObject]]()
    var homeController:HomeController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.sendSubview(toBack: self.tableView)
        self.tableView.contentInset = UIEdgeInsets(top: 108,left: 0,bottom: 0,right: 0)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        autosuggestOn = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)

        let res = data[indexPath.row]
        
        // Configure the cell...
        cell.textLabel?.text = res["name"] as? String

        return cell
    }
    
    var autosuggestOn = true
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        autosuggestOn = false
        print("Selected")
        
        let res = data[indexPath.row]
        let text = res["name"]
        if let cat = res["idcat"] as? String {
            self.dismiss(animated: true) {
                print("Dismissed")
                self.homeController?.searchTerm(text: text! as! String, idcat: cat)
            }
        }
        
        
        if let cat = res["idcat"] as? Int {
            self.dismiss(animated: true) {
                print("Dismissed")
                self.homeController?.searchTerm(text: text! as! String, idcat: String(cat))
            }
        }
        
        
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text
            
            if !autosuggestOn {
                print("Return")
                return
            }
        
            print("Search: "+searchText!)
            homeController?.currentSearchText = searchText
            DispatchQueue.global(qos: .userInitiated).async {
                
                let res = WebApi.sharedInstance.autosuggest(searchText!)
                
                
                DispatchQueue.main.async {
                    self.data = res
                    self.tableView.reloadData()
                }
            }
    }
    
    

}

extension SearchResultController : UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
    }
    
    
    
}
