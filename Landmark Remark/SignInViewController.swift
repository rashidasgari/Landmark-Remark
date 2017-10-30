//
//  SignInViewController.swift
//  Landmark Remark
//
//  Created by Rashid Asgari on 10/24/17.
//  Copyright © 2017 Rashid Asgari. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SignInViewController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate {
    
    var handle: AuthStateDidChangeListenerHandle?

    @IBAction func signIn(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        if(GIDSignIn.sharedInstance().hasAuthInKeychain())
        {
            
            DispatchQueue.main.async( execute: {
                self.performSegue(withIdentifier: "signIn", sender: self)
            })
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let authentication = user.authentication {
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential, completion: { (user, error) -> Void in
                if error != nil {
                    print("Problem at signing in with google with error : \(String(describing: error))")
                } else if error == nil {
                    print("user successfully signed in through GOOGLE! uid:\(Auth.auth().currentUser!.uid)")
                    print("signed in")
                    self.performSegue(withIdentifier: "signIn", sender: self)
                }
            })
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
