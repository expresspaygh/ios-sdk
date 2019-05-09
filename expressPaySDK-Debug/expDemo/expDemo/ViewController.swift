//
//  ViewController.swift
//  expDemo
//
//  Created by Kwei Hesse on 25/04/2019.
//  Copyright © 2019 expressPay. All rights reserved.
//

import UIKit
import expressPaySDK

class ViewController: UIViewController {
    
    var expressPay : ExpressPay!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        expressPay = ExpressPay()
        
        /**
         * Set the developnment env
         * Please ensure you set this value to false in your production code
         */
        expressPay.enableSandBox = true
        expressPay.configuration.setMyServerUrl("https://sandbox.expresspaygh.com/api/sdk/php/server.php")
    }
    
    @IBAction func pay(_ sender: Any) {
        
        let params = [
            "request" : "submit",
            "order_id" : "82373",
            "currency" : "GHS",
            "amount" : "2.00",
            "order_desc" : "Daily Plan",
            "user_name" : "testapi@expresspaygh.com",
            "first_name" : "Test",
            "last_name" : "Api",
            "email" : "testapi@expresspaygh.com",
            "phone_number" : "233244123123",
            "account_number" : "233244123123"
        ]
        
        expressPay.showProgressHUD()
        expressPay.submit(withParameters: params) { (completedSuccessfully, message, response, error) in
            self.expressPay.hideProgressHUD()
            /// Once the request is completed this listener is called with the response
            /// if the completedSuccessfully is false then there was an error
            if completedSuccessfully {
                self.displayCheckOutViewController()
            }else{
                //display error message
                self.displayAlert(withMessage: message, andTitle: "Error")
            }
        }
    }
    
    
    
    /// Displays the payment page to accept the payment method from the user
    ///
    /// When the payment is complete the CheckOutViewControllerDelegate is called
    func displayCheckOutViewController(){
        
        if let checkOutNavigationViewController = expressPay.checkOutViewController(wihtDelegate: self){
            self.present(checkOutNavigationViewController, animated: true, completion: nil)
        }
        
    }
    
    
    
    /// After the payment has been completed we query our servers to find out
    /// the status of the transaction
    /// url: https://sandbox.expresspaygh.com/api/sdk/php/server.php
    func queryTransaction(){
        
        //check to see if token has been set
        guard let token = expressPay.token else {
            //display error
            self.displayAlert(withMessage: "Sorry there was an issue. Please try again", andTitle: "Error")
            return
        }
        let params = [
            "request": "query",
            "token": token
        ]
        
        expressPay.showProgressHUD()
        expressPay.query(withParams: params) { (completedSuccessfully, message, response, error) in
            self.expressPay.hideProgressHUD()
            self.displayAlert(withMessage: message, andTitle: completedSuccessfully ? "Success" :"Error")
            
        }
    }
    
}

/// EPCheckOutViewControllerDelegate methods
extension ViewController: EPCheckOutViewControllerDelegate{
    func checkOut(viewController: EPCheckOutViewController, didSucceedWithToken token: String?) {
        dismiss(animated: false, completion: nil)
        //query the status of the transaction
        self.queryTransaction()
    }
    
    func checkOut(viewController: EPCheckOutViewController?, failedWithError error: Error) {
        dismiss(animated: false, completion: {
            //display error message
            self.displayAlert(withMessage: error.localizedDescription, andTitle: "Error")
        })
    }
    
    func checkOutCancelled(forViewController viewController: EPCheckOutViewController) {
        dismiss(animated: false, completion: {
            self.displayAlert(withMessage: "User canceled checkout", andTitle: "Error")
        })
    }
    
    
}

// MARK: Private Helper Methods
extension ViewController{
    
    /// Helper function to display alert
    ///
    /// - Parameters:
    ///   - message: message to be displayed
    ///   - title: title of the message
    private func displayAlert(withMessage message:String, andTitle title:String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { (action:UIAlertAction!) in
            
        })
        self.present(alert, animated: true, completion: nil)
    }
}

