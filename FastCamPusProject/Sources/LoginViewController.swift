//
//  ViewController.swift
//  FastCamPusProject
//
//  Created by 이주형 on 2018. 4. 8..
//  Copyright © 2018년 이주형. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController{
    
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var signInGoogle: GIDSignInButton!

    @IBOutlet weak var singInfacebook: FBSDKLoginButton!
    var alert: customAlert?
    
    
    @IBOutlet weak var SignInbtn: UIButton!
    @IBOutlet weak var createUserbtn: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        alert = customAlert()
        alert?.view = self
        singInfacebook.readPermissions = ["email", "public_profile"]
        
        
        
        
        
        GIDSignIn.sharedInstance().uiDelegate = self
        singInfacebook.delegate = self
        
        for const in singInfacebook.constraints{
            if const.firstAttribute == NSLayoutAttribute.height && const.constant == 28{
                singInfacebook.removeConstraint(const)
            }
        }

    }
    
    override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        self.navigationController?.hideNavigationBar()
    }

    @IBAction func SignIn(_ sender: UIButton) {
        print("SignIn")
        Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
            
        }
    }
    
    
    @IBAction func createUser(_ sender: UIButton) {
        print("createUser")
        let storyboryboard = UIStoryboard(name: "Lee", bundle: nil)
        let nextview: createUserViewController = storyboryboard.instantiateViewController(withIdentifier: "createUserViewController") as! createUserViewController
        
        self.navigationController?.pushViewController(nextview, animated: true)
    }
    
    
    
    @IBAction func logincheck(_ sender: UIButton) {
        print("=================== [ logout ] ===================")
        
        
     
       let user = Auth.auth().currentUser
        
        if user != nil {
            print("User is signed in.")
            print(user?.displayName! ?? "")
            print(user?.photoURL! ?? "")
        } else {
            print("No user is signed in.")
        }
    }
    @IBAction func logout(_ sender: UIButton) {
        FBSDKLoginManager.init().logOut()
        try! Auth.auth().signOut()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
}

extension LoginViewController : GIDSignInUIDelegate , FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!){
        print("왼당1")
        guard error == nil else { return }
        print("왼당2")
        
        
        print("왼당3")
        guard result != nil else { return }
        print("왼당4")
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        getFBUserData()
//        print(result)
//
//        Auth.auth().signIn(with: credential) { (user, error) in
//            guard error == nil else { return }
//            print(user?.displayName)
//            print(user?.email)
//        }
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("띠옹")
    }
    

    
    @IBAction func act_loginFB(_ sender: UIButton) {
        print("===============[ act_loginFB ]===============")
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            guard error == nil else { return }
        print("===============[ act_loginFB ]===============")
            let fbloginresult : FBSDKLoginManagerLoginResult = result!
            
            
            guard fbloginresult.grantedPermissions.contains("email") != nil else { return }
          
            
     
        }
    }
    
    
    func getFBUserData(){
//        sizeThatFits
//        let ss = FBSDKButton.init(frame: CGRect.zero)
//        ss.sizeThatFits(<#T##size: CGSize##CGSize#>)
        
        print("===============[ getFBUserData ]===============")
      guard FBSDKAccessToken.current() != nil else { return }
        
        FBSDKGraphRequest(graphPath: "me", parameters:["fields": "name, picture.type(large), email"])
            .start(completionHandler: { (connection, result, error) -> Void in
                
                guard error == nil else { return }
                print("===============[ FBSDKGraphRequest ]===============")
                
                guard let data = result as? [String:Any] else { return }
                print(data)
                guard  let image = ((data["picture"] as! [String:Any])["data"] as! [String:Any])["url"] as? String else { return }
                print(image)
                guard let name = data["name"] as? String else { return }
               print(name)
                let email = data["email"] as? String ?? ""
                print(email)
                
                
                
                

                
                
                
                
                print("===============[ FaceBook -> Firebase result ]===============")
//AuthCredential
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                
                
                
                AuthService.init().AuthCredentialLogin(token: credential, completion: { (result,user)  in
                    switch result {
                        case .success(let value):
                            print(value)
                        case .error(let error):
                            print(error)
                        case .loginerror(let loginerror):
                            print(loginerror)
                        }
                })
                    let changeRequest = Auth.auth()
                    changeRequest.signIn(with: credential) { (user, error) in
                      guard error == nil else {
                            print(error?.localizedDescription)
                            FBSDKLoginManager.init().logOut()
                            self.alert?.show(erorr: error!)
                        
                            return
                        }
                        
                        print(user?.email)
                        print(user?.photoURL?.absoluteString)
                        print(user?.uid)
                        print(user?.displayName)
                        

                        AuthService.init().signInAPI(email: (user?.email) ?? "", photoURL: (image), displayName: (user?.displayName)!, uid: (user?.uid)!, completion: { (restul) in
                            switch restul {
                            case .success(let value):
                                print(value)
                            case .error(let error):
                                print(error)
                            case .loginerror(let loginError):
                                print(loginError)
                            }
                        })
                        
                        guard error != nil else { return }
                        let changeRequest = changeRequest.currentUser?.createProfileChangeRequest()
                        changeRequest?.photoURL = URL(fileURLWithPath: image)
                        
                        changeRequest?.commitChanges { (error) in
                            
                            print(error?.localizedDescription)
                        }
                    }//firebase end
                
            })
        
    }
}



