//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit


class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
, UIScrollViewDelegate, MKMapViewDelegate{

    var businesses: [Business]!
    
    //var data: [Business]!
    
    var filteredData: [Business]!
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchBar = UISearchBar()
    
    var isMoreDataLoading = false
    
    var offset = 20
    
    var limit = 10
    
    //weak var thumb: UIImageView?
    
    @IBOutlet weak var mapView: MKMapView!
    
    //@IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.alpha = 0.0
        
        self.searchBar.sizeToFit()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        //use auto-layout constraint rules
        tableView.estimatedRowHeight = 120
        //prevents auto-layout from calculating all of the scroll height dimension at once
        
        navigationItem.titleView = self.searchBar
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Map", style: .Plain, target: self, action: "mapTapped")
        navigationItem.leftBarButtonItem!.tintColor = UIColor.whiteColor()
        
        
        
        

        Business.searchWithTerm("Thai", offset: 0, limit: 20, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            //print(self.data)
            self.filteredData = self.businesses
            self.tableView.reloadData()
            //businesses are arranged in the Yelp API by a code
            
            
        })
        
        
        
        

/* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
        
        
*/
        // set the region to display, this also sets a correct zoom level
        // set starting center location in San Francisco
        let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
        goToLocation(centerLocation)
        
        /*let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 37.7833, longitude: -122.4167)
        annotation.title = "hello"
        self.mapView.addAnnotation(annotation)*/
        
    
    }
    
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, business: Business) {
        business.annotation = MKPointAnnotation()
        business.annotation!.coordinate = coordinate
        business.annotation!.title = business.name
        //self.mapViewSet(mapView, viewForAnnotation: business.annotation!, business: business )
        self.mapView.addAnnotation(business.annotation!)
        //print("ISITWORKING")
    }
    
    /*func mapViewSet(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation, business: Business) -> MKAnnotationView? {
        let identifier = "customAnnotationView"
        if business.imageURL != nil {
            
        print(business.imageURL)
        //let thumb = thumb.setImageWithURL(business.imageURL!)
        // custom image annotation
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        if (annotationView == nil) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        else {
            annotationView!.annotation = annotation
        }
        annotationView!.image = thumb.image
        return annotationView
        }
        
        return nil
    }*/
    
    func mapTapped() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.mapView.alpha = 1.0
            self.tableView.alpha = 0.0
            
        })
        
        for business in filteredData {
            self.addAnnotationAtCoordinate(business.geoLocation, business: business)
            print(business.geoLocation)
        }
        
        
        
    
        self.searchBar.alpha = 0.0
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "List", style: .Plain, target: self, action: "listTapped")
        navigationItem.leftBarButtonItem!.tintColor = UIColor.whiteColor()
    }
    
    func listTapped() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.mapView.alpha = 0.0
            self.tableView.alpha = 1.0
            
        })
        self.searchBar.alpha = 1.0
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Map", style: .Plain, target: self, action: "mapTapped")
        navigationItem.leftBarButtonItem!.tintColor = UIColor.whiteColor()
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    func loadMoreData() {
        Business.searchWithTerm("Thai", offset: self.offset, limit: 20, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.isMoreDataLoading = false
            self.filteredData = self.businesses
            for business in businesses {
                print(business.name)
                //if let business.thumbImageView = business.thumbImageView? {
                    self.filteredData.append(business)
                //}
                
                
            }
            self.businesses = self.filteredData
            self.offset += 20
            //self.limit += 20
            print(self.offset)
            
            self.tableView.reloadData()
         })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredData != nil {
            print("******* \(filteredData.count) *******")
            return filteredData.count
        } else {
            return 0
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = filteredData[indexPath.row]
        //cell.textLabel?.text = filteredData[indexPath.row]
        
        return cell
    }
    
    //SEARCH
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        print("CALLED")
        if searchText.isEmpty {
            filteredData = businesses
            print(filteredData)
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredData = businesses.filter({(dataItem: Business) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if dataItem.name!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    //SEARCH
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            dismissKeyboard()
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        searchBar.endEditing(true)
    }
    
    //SCROLL
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading){
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                loadMoreData()
            }
        }
        
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
