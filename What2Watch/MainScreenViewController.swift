//
//  ViewController.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import SWRevealViewController
import UIActivityIndicator_for_SDWebImage

class MainScreenViewController: UIViewController {
 
    @IBOutlet var profileInfo: UILabel!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var poster: UIImageView!
    @IBOutlet var btnMenu: UIButton?
    
    var currentIndex:Int = 0   /// current image index
    var numberOfItems: Int = 0  /// number of images
    
    var ref:FIRDatabaseReference!
    var user: FIRUser!
    
    var movies:Array<[String:AnyObject]> = []


    override func viewDidLoad() {
        super.viewDidLoad()
        
        try! FIRAuth.auth()?.signOut()
        // Init menu button action for menu
        if let revealVC = self.revealViewController() {
            self.btnMenu?.addTarget(revealVC, action: #selector(revealVC.revealToggle(_:)), forControlEvents: .TouchUpInside)
//            self.view.addGestureRecognizer(revealVC.panGestureRecognizer());
//            self.navigationController?.navigationBar.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
        
        ref = FIRDatabase.database().reference()
        //let userID = FIRAuth.auth()?.currentUser?.uid
        //firebaseID : -KOEX9GVlOqAe-jZ6sYB
        //id key : imdbID
//        ref.child("movies").child("-KOEX9GVlOqAe-jZ6sYB").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
//            if let movieID = snapshot.value!["imdbID"]{
//                let movieIDString = movieID as! String!
//                let posterURL = "http://img.omdbapi.com/?i=\(movieIDString)&apikey=57288a3b&h=1000"
//                let posterNSURL = NSURL(string: "\(posterURL)")
//                self.poster.sd_setImageWithURL(posterNSURL)
//            }
//        })
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(MainScreenViewController.respondToSwipe(_:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(MainScreenViewController.respondToSwipe(_:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(MainScreenViewController.respondToSwipe(_:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(MainScreenViewController.respondToSwipe(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
    }
        
        func respondToSwipe(gesture: UIGestureRecognizer) {
            if let swipeGesture = gesture as? UISwipeGestureRecognizer {
                switch swipeGesture.direction {
                case UISwipeGestureRecognizerDirection.Right:
                    self.swipeRight()
                    //self.swipeLeft()
                    print("Right")
                case UISwipeGestureRecognizerDirection.Left:
                    self.swipeLeft()
                    print("Left")
                case UISwipeGestureRecognizerDirection.Up:
                    self.swipeLeft()
                    print("Up")
                case UISwipeGestureRecognizerDirection.Down:
                    self.swipeLeft()
                    print("Down")
                default:
                    break
                }
            }
        }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.LoadMoreMovieRecords(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     LoadMoreMovieRecords()
     Will load 10 records on each call annd appent to main array
     */
    func LoadMoreMovieRecords( isFirstCall:Bool )
    {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        if isFirstCall == true {
            ref.child("movies").queryOrderedByKey().queryLimitedToFirst(10).observeEventType(.Value, withBlock: { snapshot in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                if snapshot.exists() {
                    print(snapshot.childrenCount)
                    let enumerator = snapshot.children
                    while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                        print("rest.key =>>  \(rest.key) =>>   \(rest.value)")
                        if var dic = rest.value as? [String:AnyObject] {
                            dic["key"] = rest.key
                            self.movies.append(dic)
                        }
                    }
                    self.currentIndex = 0
                    self.getImage(0)
                    self.numberOfItems += Int(snapshot.childrenCount)
                } else {
                    // Not found any movie
                }
                
//                let dic: NSDictionary = snapshot.value as! NSDictionary
//                //print(dic)
//                let jsonData: NSData = try! NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions.PrettyPrinted)
//                let jsonDic = try! NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)
//                //print(jsonDic.allValues)
//                for item in jsonDic.allValues {
//                    
//                    if item.isKindOfClass(NSDictionary) {
//                        let obj = item as! NSDictionary
//                        let imdbIDStr = obj.objectForKey("imdbID") as! String
//                        self.imdbArray.append(imdbIDStr)
//                    }
//                }
//                self.currentIndex = self.numberOfItems
//                self.getImage(self.imdbArray[self.numberOfItems])
//                self.numberOfItems += dic.count
                
                
                }, withCancelBlock: { error in
                    print(error.description)
            })
        }
        else
        {
            //.queryOrderedByKey()
            //.queryStartingAtValue(5)
            //.queryEndingAtValue(10)
            
            ref.child("movies").queryOrderedByKey().queryStartingAtValue(movies.last!["key"] as! String).queryLimitedToFirst(10).observeEventType(.Value, withBlock: { snapshot in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                if snapshot.exists() {
                    print(snapshot.childrenCount)
                    let enumerator = snapshot.children
                    while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                        print("rest.key =>>  \(rest.key) =>>   \(rest.value)")
                        if var dic = rest.value as? [String:AnyObject] {
                            dic["key"] = rest.key
                            self.movies.append(dic)
                        }
                    }
                    self.currentIndex += 1
                    self.numberOfItems += Int(snapshot.childrenCount)
                    self.getImage(self.currentIndex)
                } else {
                    // Not found any movie
                }
                }, withCancelBlock: { error in
                    print(error.description)
            })
        }
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            AppState.sharedInstance.signedIn = false
            dismissViewControllerAnimated(true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }
        let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SignInViewController") as! FirebaseSignInViewController!
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    @IBAction func menuButton(sender: AnyObject) {
        
    }
    
    
    
    /*      */
    
    func getImage(forIndex: Int)
    {
        if forIndex >= movies.count {
            return
        }
        
        let imdbID = movies[forIndex]["imdbID"] as? String ?? ""
        let posterURL = "http://img.omdbapi.com/?i=\(imdbID)&apikey=57288a3b&h=1000"
        let posterNSURL = NSURL(string: "\(posterURL)")
        
        print("Movie: \(imdbID) , Image: \(posterURL)")
        
//        self.poster.sd_setImageWithURL(posterNSURL, placeholderImage: UIImage(named: "placeholder"))
        
        self.poster.sd_cancelCurrentImageLoad()
        //self.poster.setImageWithURL(posterNSURL, placeholderImage: UIImage(named: "placeholder"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        self.poster.setImageWithURL(posterNSURL,
                                    placeholderImage: UIImage(named: "placeholder"),
                                    options: SDWebImageOptions.AllowInvalidSSLCertificates,
                                    completed: { (imgPoster, error, cacheType, urlPoster) in
                                        if error != nil {
                                            print(error)
                                        }
                                    },
                                    usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    }
    
    func swipeLeft() {
        if self.currentIndex < self.numberOfItems-1 {
            self.currentIndex = self.currentIndex + 1
            self.getImage(self.currentIndex)
        }
        else if self.currentIndex == self.numberOfItems-1 {
            // We have to Load Next set of records
            self.LoadMoreMovieRecords(false)
        }
    }
    
    func swipeRight() {
        if self.currentIndex > 0 {
            self.currentIndex = self.currentIndex - 1
            self.getImage(self.currentIndex)
        }
    }
    
    func swipeUp() {
        self.swipeRight()
    }
    
    func swipeDown() {
        self.swipeLeft()
    }
    
}
