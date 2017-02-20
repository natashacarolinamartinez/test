//
//  MainViewController.swift
//  NatashaMartinez
//
//  Created by Natasha M on 2/19/17.
//  Copyright © 2017 Martinezpc. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var appNumberField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func gotoMainList(_ sender: Any) {
        
        if self.appNumberField.hasText {
            
         self.performSegue(withIdentifier: "goToCollection", sender: self)
            
        } else {
            
            displayAlertMessage(viewController: self, message: "Por favor ingresa la cantidad de apps que quieres filtrar :) ", sender: self.view)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToCollection" {
        
            let destination = segue.destination as! CollectionViewController
            destination.totalAppsToShow = self.appNumberField.text!
        }
    }
}
