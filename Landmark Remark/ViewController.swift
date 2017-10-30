//
//  ViewController.swift
//  Landmark Remark
//
//  Created by Rashid Asgari on 10/23/17.
//  Copyright © 2017 Rashid Asgari. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import GoogleSignIn
class remarksAnnotation: MKPointAnnotation {
}

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate,UITextViewDelegate,UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var newRemark: UIButton!
    var handle: AuthStateDidChangeListenerHandle?
    @IBOutlet weak var mapButtonContainter: UIView!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var userName = ""
    var fullName = ""
    var ref: DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle?
    var remarks: [DataSnapshot]! = []
    var remarksArray : NSMutableArray! = []
    var pointAnnotation:remarksAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var userLocation :CLLocation!
    var remarkString = ""
    let screenSize = UIScreen.main.bounds
    let newRemarkView = UIView()
    var isSearchVisible = false
    var blurEffectView = UIVisualEffectView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure the firebase DB
        configureDatabase()
        
        //Setting up location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 100
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //Search Bar
        searchBar.delegate = self

        //Adding the "current-location button" to the containter at the bottom left of the mapview
        let currentLocationButton = MKUserTrackingButton(mapView: self.mapView)
        currentLocationButton.frame = CGRect.init(x: 0, y: 55, width: 59, height: 55)
        self.mapButtonContainter.addSubview(currentLocationButton)
        
        //Get the username & fullname from the FireBase authentication listener
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if (user != nil){
                self.fullName = (user?.displayName)!
                self.userName = (user?.email)!
            }
        }
    }

// MARK: - FireBase DB Methods
    @objc func sendMessage() {
        var mdata = [String: String]()
        if (userLocation != nil) {
            mdata["userName"] = self.fullName
            mdata["lat"] = String(format:"%f",self.userLocation.coordinate.latitude)
            mdata["long"] = String(format:"%f",self.userLocation.coordinate.longitude)
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let result = formatter.string(from: date)
            mdata["dateTime"] = result
            mdata["remark"] = remarkString
            // Push data to Firebase Database
            self.ref.child("remarks").childByAutoId().setValue(mdata)
            self.removeBlur()
            self.dismissRemarkView()
        }
    }
    
    deinit {
        if _refHandle != nil {
            self.ref.child("remarks").removeObserver(withHandle: _refHandle!)
        }
    }
    
    func configureDatabase() {
        
        ref = Database.database().reference()
        // Listen for new messages in the Firebase database
        _refHandle = self.ref.child("remarks").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.remarks.append(snapshot)
            
            //Cast DataSnapshots to dictionary
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            
            //Add the dictionaries to a dictionary for further access
            self?.remarksArray.add(postDict)

            //Add remarks annotation as datasnapshots are unwrapped
            self?.addRemarksAnnotationsOnMap(dictionary: postDict)
        })
    }
    
// MARK: - MapView and Annotation
    func addRemarksAnnotationsOnMap(dictionary:[String:AnyObject]){
        let remarksLocationtion = CLLocation(latitude: (dictionary["lat"]?.doubleValue)!, longitude: (dictionary["long"]?.doubleValue)!)
        pointAnnotation = remarksAnnotation()

        pointAnnotation.coordinate = remarksLocationtion.coordinate
        pointAnnotation.title = dictionary["userName"] as? String
        pointAnnotation.subtitle = dictionary["remark"] as? String
        pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
        mapView.addAnnotation(pinAnnotationView.annotation!)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        // Better to make this class property
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            //If the annotation is mine the pin is in blue, for other users its red
            annotationView.canShowCallout = true
            if(annotation.title! == fullName)
            {
                annotationView.image = UIImage(named: "icons8-marker-red")
            }else{
                annotationView.image = UIImage(named: "icons8-marker")
            }
        }
        
        return annotationView
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Zooming in on user's current location
        userLocation = locations.last
        let camera = MKMapCamera(lookingAtCenter: (userLocation?.coordinate)!, fromEyeCoordinate: (userLocation?.coordinate)!, eyeAltitude: 50000)
        mapView.setCamera(camera, animated: true)
    }
// MARK: - SearchView methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchString = searchBar.text
        var filter = NSPredicate()
        //If the search bar scope is at index 0 search for remarks and if 1 search for username
        if searchBar.selectedScopeButtonIndex == 0 {
            filter = NSPredicate(format: "remark CONTAINS[c] %@", searchString!)
        }
        else{
            filter = NSPredicate(format: "userName CONTAINS[c] %@", searchString!)
        }
        let filteredArray = remarksArray.filtered(using: filter)
        mapView.removeAnnotations(mapView.annotations)
        for dict in filteredArray {
            addRemarksAnnotationsOnMap(dictionary: dict as! [String : AnyObject])
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        mapView.removeAnnotations(mapView.annotations)
        configureDatabase()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        remarkString = textView.text
    }
    
// MARK: - Misc
    func addBlur(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
    }
    func removeBlur(){
        blurEffectView.removeFromSuperview()
    }
    
    @IBAction func newNoteBTNTapped(_ sender: Any)
    {
        addBlur()
        
        //The UIView containing a UITextView for inserting new remarks + a save button and a cancel button
        newRemarkView.backgroundColor = UIColor.white
        newRemarkView.layer.cornerRadius = 10
        self.view.addSubview(newRemarkView)
        
        //The UITextView for inserting the remark
        let remarkTextView = UITextView()
        remarkTextView.delegate = self
        remarkTextView.frame = CGRect(x: 5, y: 5, width: screenSize.width-60, height: 200)
        remarkTextView.isEditable = true
        remarkTextView.layer.borderWidth = 1
        remarkTextView.layer.cornerRadius = 5
        newRemarkView.addSubview(remarkTextView)
        
        //The cancel button
        let cancelButton = UIButton()
        cancelButton.frame = CGRect(x: 5, y: remarkTextView.frame.size.height + 10, width: (remarkTextView.frame.size.width/2)-10, height: 50)
        cancelButton.addTarget(self, action: #selector(dismissRemarkView), for: .touchUpInside)
        cancelButton.backgroundColor = UIColor.red
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.isUserInteractionEnabled = true
        cancelButton.titleLabel?.textColor = UIColor.white
        newRemarkView.addSubview(cancelButton)
        
        //The save button
        let saveButton = UIButton()
        saveButton.frame = CGRect(x: cancelButton.frame.size.width+25, y: remarkTextView.frame.size.height + 10, width: (remarkTextView.frame.size.width/2)-10, height: 50)
        saveButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        saveButton.backgroundColor = UIColor.green
        saveButton.setTitle("Save", for: UIControlState.normal)
        saveButton.isUserInteractionEnabled = true
        saveButton.titleLabel?.textColor = UIColor.white
        newRemarkView.addSubview(saveButton)
        
        newRemarkView.frame = CGRect(x: 25, y: -500, width: screenSize.width-50, height: 270)
        UIView.animate(withDuration: 0.25, animations: {
            self.newRemarkView.frame = CGRect(x: 25, y: 100, width: self.screenSize.width-50, height: 270)
        })
        
        newRemark.isEnabled = false
        self.mapView.isUserInteractionEnabled = false
        self.searchBar.isUserInteractionEnabled = false
    }
    
    @objc func dismissRemarkView()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.newRemarkView.frame = CGRect(x: 25, y: -500, width: self.screenSize.width-50, height: 270)
            
        }) { (true) in
            self.removeBlur()
            self.newRemarkView.removeFromSuperview()
            self.mapView.isUserInteractionEnabled = true
            self.newRemark.isEnabled = true
            self.searchBar.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func signOut(_ sender: Any) {
        
        GIDSignIn.sharedInstance().signOut()
        self.performSegue(withIdentifier: "signOut", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

