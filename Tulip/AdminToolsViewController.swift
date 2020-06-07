//
//  AdminToolsViewController.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 6/6/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import UIKit

class AdminToolsViewController: UIViewController {

    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func notifyUsersOfServerDowntimeAction(_ sender: Any) {
        let alertController = UIAlertController(title: "How many minutes from now?", message: "", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = "minutes until downtime"
        })
        
        alertController.addAction(UIAlertAction(title: "Send message to users", style: .default, handler: {_ in self.sendDowntimeAlert(minutesUntilDowntime: Int(alertController.textFields![0].text!)!)}))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sendDowntimeAlert(minutesUntilDowntime:Int) {
        global.sendMessage(dictionaryMessage: ["instruction": "serverDowntimeAlert", "minutesUntilDowntime": minutesUntilDowntime], vc: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
