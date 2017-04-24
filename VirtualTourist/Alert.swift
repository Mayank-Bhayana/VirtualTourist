//
//  Alert.swift
//  VirtualTourist
//
//  Created by Sahil Dhawan on 24/04/17.
//  Copyright © 2017 Sahil Dhawan. All rights reserved.
//

import Foundation
import UIKit

class Alert : NSObject
{
    func showAlert(_ ViewController : UIViewController, _ msg:String)
    {
        let controller = UIAlertController(title: "Virtual Tourist", message: msg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
        controller.addAction(alertAction)
        ViewController.present(controller, animated: true, completion: nil)
    }
}
