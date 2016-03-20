//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Johnny Pham on 3/20/16.
//  Copyright © 2016 Johnny Pham. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewController:FiltersViewController, didUpdateFilters filters: [String:AnyObject], deal: Bool, sort: Int, radius: Double)
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate, SwitchDealDelegate {
    
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    var selectedDistance = 0
    var categories: [[String:String]]!
    var radius: [[String:String]]!
    var checked: [Bool]!
    var deals = false
    var switchStates = [Int:Bool]()
    var switchRadius = [Int:Bool]()
    var isExpended: [Int:Bool]! = [Int:Bool]()
    var sortType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        radius = Radius()
        checked = [Bool](count: radius.count, repeatedValue: false)
        categories = yelpCategories()
        tableView.registerNib(UINib(nibName: "SeeAllView", bundle: nil), forCellReuseIdentifier: "seeAllCell")
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancleButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        var filters = [String : AnyObject]()
        var selectedCategories = [String]()
        for (row, isSelected) in switchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        let radiusValue = Double(radius[selectedDistance]["code"]!)
        delegate?.filtersViewController?(self, didUpdateFilters: filters, deal: deals, sort: sortType, radius: radiusValue!)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            if let expanded = isExpended[section] {
                return expanded ? radius.count : 1
            } else {
                return 1
            }
        } else if section == 2 {
            if let expended = isExpended[section] {
                return expended ? categories.count : 4
            } else {
                return 4
            }
        }
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionName = String!()
        if section == 0 {
            sectionName = "Deal"
        } else if section == 1 {
            sectionName = "Radius"
        } else if section == 2 {
            sectionName = "Categories"
        }
        return sectionName
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("DealCell", forIndexPath: indexPath) as! DealCell
            cell.delegate = self
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("RadiusCell", forIndexPath: indexPath) as! RadiusCell
            var rowIndex = 0
            if tableView.numberOfRowsInSection(indexPath.section) == 1 {
                rowIndex = selectedDistance
                cell.distanceLabel.text = radius[rowIndex]["name"]
                cell.accessoryType = .Checkmark
            } else {
                rowIndex = indexPath.row
                if indexPath.row == selectedDistance {
                    cell.accessoryType = .Checkmark
                } else {
                    cell.accessoryType = .None
                }
            }
            cell.distanceLabel.text = radius[rowIndex]["name"]
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! FilterCell
            if tableView.numberOfRowsInSection(indexPath.section) != categories.count {
                if indexPath.row == 3 {
                    cell.hidden = true
                    let seeAllCell = tableView.dequeueReusableCellWithIdentifier("seeAllCell")
                    return seeAllCell!
                }
            }
            cell.categoriesLabel.text = self.categories[indexPath.row]["name"]
            cell.delegate = self
            cell.onSwitch.on = switchStates[indexPath.row] ?? false
            return cell
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if let expanded = isExpended[indexPath.section] {
                isExpended[indexPath.section] = !expanded
                if (isExpended[indexPath.section] == false) {
                    if (indexPath.section == 1) {
                        checked[indexPath.row] = !checked[indexPath.row]
                        selectedDistance = indexPath.row
                    }
                }
            } else {
                isExpended[indexPath.section] = true
            }
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
        } else if indexPath.section == 2 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if indexPath.row == 3 && tableView.numberOfRowsInSection(indexPath.section) == 4 {
                if let expanded = isExpended[indexPath.section] {
                    isExpended[indexPath.section] = !expanded
                } else {
                    isExpended[indexPath.section] = true
                }
                tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
            }
            
        }
    }
    
    func switchDealCell(switchCell: DealCell, didChangeValue value: Bool) {
        deals = value
        
    }
    
    func switchCell(switchCell: FilterCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        switchStates[indexPath.row] = value
        
    }
    
    @IBAction func getSortType(sender: AnyObject) {
        sortType = segmentControl.selectedSegmentIndex
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    func Radius () -> [[String:String]] {
        return [["name" : "Auto", "code": "1609"],
            ["name" : "2 miles", "code": "3218"],
            ["name" : "5 miles", "code": "8045"]
        ]
    }
    func yelpCategories() -> [[String:String]]{
        return [["name" : "Afghan", "code": "afghani"],
            ["name" : "African", "code": "african"],
            ["name" : "American, New", "code": "newamerican"],
            ["name" : "American, Traditional", "code": "tradamerican"],
            ["name" : "Arabian", "code": "arabian"],
            ["name" : "Argentine", "code": "argentine"],
            ["name" : "Armenian", "code": "armenian"],
            ["name" : "Asian Fusion", "code": "asianfusion"],
            ["name" : "Asturian", "code": "asturian"],
            ["name" : "Australian", "code": "australian"],
            ["name" : "Austrian", "code": "austrian"],
            ["name" : "Baguettes", "code": "baguettes"],
            ["name" : "Bangladeshi", "code": "bangladeshi"],
            ["name" : "Barbeque", "code": "bbq"],
            ["name" : "Basque", "code": "basque"],
            ["name" : "Bavarian", "code": "bavarian"],
            ["name" : "Beer Garden", "code": "beergarden"],
            ["name" : "Beer Hall", "code": "beerhall"],
            ["name" : "Beisl", "code": "beisl"],
            ["name" : "Belgian", "code": "belgian"],
            ["name" : "Bistros", "code": "bistros"],
            ["name" : "Black Sea", "code": "blacksea"],
            ["name" : "Brasseries", "code": "brasseries"],
            ["name" : "Brazilian", "code": "brazilian"],
            ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
            ["name" : "British", "code": "british"],
            ["name" : "Buffets", "code": "buffets"],
            ["name" : "Bulgarian", "code": "bulgarian"],
            ["name" : "Burgers", "code": "burgers"],
            ["name" : "Burmese", "code": "burmese"],
            ["name" : "Cafes", "code": "cafes"],
            ["name" : "Cafeteria", "code": "cafeteria"],
            ["name" : "Cajun/Creole", "code": "cajun"],
            ["name" : "Cambodian", "code": "cambodian"],
            ["name" : "Canadian", "code": "New)"],
            ["name" : "Canteen", "code": "canteen"],
            ["name" : "Caribbean", "code": "caribbean"],
            ["name" : "Catalan", "code": "catalan"],
            ["name" : "Chech", "code": "chech"],
            ["name" : "Cheesesteaks", "code": "cheesesteaks"],
            ["name" : "Chicken Shop", "code": "chickenshop"],
            ["name" : "Chicken Wings", "code": "chicken_wings"],
            ["name" : "Chilean", "code": "chilean"],
            ["name" : "Chinese", "code": "chinese"],
            ["name" : "Comfort Food", "code": "comfortfood"],
            ["name" : "Corsican", "code": "corsican"],
            ["name" : "Creperies", "code": "creperies"],
            ["name" : "Cuban", "code": "cuban"],
            ["name" : "Curry Sausage", "code": "currysausage"],
            ["name" : "Cypriot", "code": "cypriot"],
            ["name" : "Czech", "code": "czech"],
            ["name" : "Czech/Slovakian", "code": "czechslovakian"],
            ["name" : "Danish", "code": "danish"],
            ["name" : "Delis", "code": "delis"],
            ["name" : "Diners", "code": "diners"],
            ["name" : "Dumplings", "code": "dumplings"],
            ["name" : "Eastern European", "code": "eastern_european"],
            ["name" : "Ethiopian", "code": "ethiopian"],
            ["name" : "Fast Food", "code": "hotdogs"],
            ["name" : "Filipino", "code": "filipino"],
            ["name" : "Fish & Chips", "code": "fishnchips"],
            ["name" : "Fondue", "code": "fondue"],
            ["name" : "Food Court", "code": "food_court"],
            ["name" : "Food Stands", "code": "foodstands"],
            ["name" : "French", "code": "french"],
            ["name" : "French Southwest", "code": "sud_ouest"],
            ["name" : "Galician", "code": "galician"],
            ["name" : "Gastropubs", "code": "gastropubs"],
            ["name" : "Georgian", "code": "georgian"],
            ["name" : "German", "code": "german"],
            ["name" : "Giblets", "code": "giblets"],
            ["name" : "Gluten-Free", "code": "gluten_free"],
            ["name" : "Greek", "code": "greek"],
            ["name" : "Halal", "code": "halal"],
            ["name" : "Hawaiian", "code": "hawaiian"],
            ["name" : "Heuriger", "code": "heuriger"],
            ["name" : "Himalayan/Nepalese", "code": "himalayan"],
            ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
            ["name" : "Hot Dogs", "code": "hotdog"],
            ["name" : "Hot Pot", "code": "hotpot"],
            ["name" : "Hungarian", "code": "hungarian"],
            ["name" : "Iberian", "code": "iberian"],
            ["name" : "Indian", "code": "indpak"],
            ["name" : "Indonesian", "code": "indonesian"],
            ["name" : "International", "code": "international"],
            ["name" : "Irish", "code": "irish"],
            ["name" : "Island Pub", "code": "island_pub"],
            ["name" : "Israeli", "code": "israeli"],
            ["name" : "Italian", "code": "italian"],
            ["name" : "Japanese", "code": "japanese"],
            ["name" : "Jewish", "code": "jewish"],
            ["name" : "Kebab", "code": "kebab"],
            ["name" : "Korean", "code": "korean"],
            ["name" : "Kosher", "code": "kosher"],
            ["name" : "Kurdish", "code": "kurdish"],
            ["name" : "Laos", "code": "laos"],
            ["name" : "Laotian", "code": "laotian"],
            ["name" : "Latin American", "code": "latin"],
            ["name" : "Live/Raw Food", "code": "raw_food"],
            ["name" : "Lyonnais", "code": "lyonnais"],
            ["name" : "Malaysian", "code": "malaysian"],
            ["name" : "Meatballs", "code": "meatballs"],
            ["name" : "Mediterranean", "code": "mediterranean"],
            ["name" : "Mexican", "code": "mexican"],
            ["name" : "Middle Eastern", "code": "mideastern"],
            ["name" : "Milk Bars", "code": "milkbars"],
            ["name" : "Modern Australian", "code": "modern_australian"],
            ["name" : "Modern European", "code": "modern_european"],
            ["name" : "Mongolian", "code": "mongolian"],
            ["name" : "Moroccan", "code": "moroccan"],
            ["name" : "New Zealand", "code": "newzealand"],
            ["name" : "Night Food", "code": "nightfood"],
            ["name" : "Norcinerie", "code": "norcinerie"],
            ["name" : "Open Sandwiches", "code": "opensandwiches"],
            ["name" : "Oriental", "code": "oriental"],
            ["name" : "Pakistani", "code": "pakistani"],
            ["name" : "Parent Cafes", "code": "eltern_cafes"],
            ["name" : "Parma", "code": "parma"],
            ["name" : "Persian/Iranian", "code": "persian"],
            ["name" : "Peruvian", "code": "peruvian"],
            ["name" : "Pita", "code": "pita"],
            ["name" : "Pizza", "code": "pizza"],
            ["name" : "Polish", "code": "polish"],
            ["name" : "Portuguese", "code": "portuguese"],
            ["name" : "Potatoes", "code": "potatoes"],
            ["name" : "Poutineries", "code": "poutineries"],
            ["name" : "Pub Food", "code": "pubfood"],
            ["name" : "Rice", "code": "riceshop"],
            ["name" : "Romanian", "code": "romanian"],
            ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
            ["name" : "Rumanian", "code": "rumanian"],
            ["name" : "Russian", "code": "russian"],
            ["name" : "Salad", "code": "salad"],
            ["name" : "Sandwiches", "code": "sandwiches"],
            ["name" : "Scandinavian", "code": "scandinavian"],
            ["name" : "Scottish", "code": "scottish"],
            ["name" : "Seafood", "code": "seafood"],
            ["name" : "Serbo Croatian", "code": "serbocroatian"],
            ["name" : "Signature Cuisine", "code": "signature_cuisine"],
            ["name" : "Singaporean", "code": "singaporean"],
            ["name" : "Slovakian", "code": "slovakian"],
            ["name" : "Soul Food", "code": "soulfood"],
            ["name" : "Soup", "code": "soup"],
            ["name" : "Southern", "code": "southern"],
            ["name" : "Spanish", "code": "spanish"],
            ["name" : "Steakhouses", "code": "steak"],
            ["name" : "Sushi Bars", "code": "sushi"],
            ["name" : "Swabian", "code": "swabian"],
            ["name" : "Swedish", "code": "swedish"],
            ["name" : "Swiss Food", "code": "swissfood"],
            ["name" : "Tabernas", "code": "tabernas"],
            ["name" : "Taiwanese", "code": "taiwanese"],
            ["name" : "Tapas Bars", "code": "tapas"],
            ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
            ["name" : "Tex-Mex", "code": "tex-mex"],
            ["name" : "Thai", "code": "thai"],
            ["name" : "Traditional Norwegian", "code": "norwegian"],
            ["name" : "Traditional Swedish", "code": "traditional_swedish"],
            ["name" : "Trattorie", "code": "trattorie"],
            ["name" : "Turkish", "code": "turkish"],
            ["name" : "Ukrainian", "code": "ukrainian"],
            ["name" : "Uzbek", "code": "uzbek"],
            ["name" : "Vegan", "code": "vegan"],
            ["name" : "Vegetarian", "code": "vegetarian"],
            ["name" : "Venison", "code": "venison"],
            ["name" : "Vietnamese", "code": "vietnamese"],
            ["name" : "Wok", "code": "wok"],
            ["name" : "Wraps", "code": "wraps"],
            ["name" : "Yugoslav", "code": "yugoslav"]]
    }
}
