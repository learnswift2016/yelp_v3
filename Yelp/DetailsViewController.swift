//
//  DetailsViewController.swift
//  Yelp
//
//  Created by Johnny Pham on 3/20/16.
//  Copyright © 2016 Johnny Pham. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailsViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var categoriesLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var reviewLabel: UILabel!
    @IBOutlet var ratingImageView: UIImageView!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var thumbImageView: UIImageView!
    
    var business : Business!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        thumbImageView.setImageWithURL(business.imageURL!)
        categoriesLabel.text = business.categories
        addressLabel.text = business.address
        distanceLabel.text = business.distance
        reviewLabel.text = "\(business.reviewCount!) Reviews"
        ratingImageView.setImageWithURL(business.ratingImageURL!)
        title = business.name
        let location = CLLocationCoordinate2D(latitude: business.latitude!, longitude: business.longtitude!)
        let span = MKCoordinateSpanMake(0.02, 0.02)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = business.name
        annotation.subtitle = business.categories
        mapView.addAnnotation(annotation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
