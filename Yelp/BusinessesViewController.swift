//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Johnny Pham on 3/20/16.
//  Copyright © 2016 Johnny Pham. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate {
    
    var businesses: [Business]!
    var searchBar: UISearchBar!
    var searchText = "Restaurants"
    let recognizer = UITapGestureRecognizer()
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //searchBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        //custom NavigationController
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        searchWithTerm(searchText)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        recognizer.addTarget(self, action: "dismissSearchView")
        view.addGestureRecognizer(recognizer)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        view.removeGestureRecognizer(recognizer)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchWithTerm(searchText)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueFilter" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FiltersViewController
            filtersViewController.delegate = self
        }
        if segue.identifier == "segueDetail" {
            let detailsViewController = segue.destinationViewController as! DetailsViewController
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)!
            detailsViewController.business = self.businesses[indexPath.row]
        }
        if segue.identifier == "segueMap" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let mapViewController = navigationController.topViewController as! MapViewController
            mapViewController.businesses = businesses
        }
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject], deal: Bool, sort: Int, radius: Double) {
        let categories = filters["categories"] as? [String]
        var sortType : YelpSortMode?
        if sort == 0 {
            sortType = YelpSortMode.BestMatched
        } else if sort == 1 {
            sortType = YelpSortMode.HighestRated
        } else {
            sortType = YelpSortMode.Distance
        }
        Business.searchWithTerm("Restaurant", sort: sortType, categories: categories, deals: deal, radius: radius) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
    
    func dismissSearchView() {
        searchBar.resignFirstResponder()
        view.endEditing(true)
    }
    
    func searchWithTerm(term: String) {
        Business.searchWithTerm(term) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
}
