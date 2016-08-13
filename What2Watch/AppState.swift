//
//  AppState.swift
//  What2Watch
//
//  Created by Dustin Allen on 7/15/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import Foundation
import Firebase

class AppState: NSObject {
    
    static let sharedInstance = AppState()
    
    var signedIn = false
    var displayName: String?
    var photoUrl: NSURL?    
    var currentUser: FIRDataSnapshot!
    var movieWatched: String?
    var timeWatched: String?
    var watchlistCount: String?
}