//
//  ProfileViewController.swift
//  Tulip
//
//  Created by Stefan Kuklinsky on 5/31/20.
//  Copyright © 2020 Stefan Kuklinsky. All rights reserved.
//

import UIKit



class ProfileViewController: UIViewController {

    @IBOutlet weak var contentTableView: UITableView!
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var posts:[Poast] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentTableView.dataSource = self
        contentTableView.delegate = self
        contentTableView.allowsSelection = false
        
        contentTableView.separatorStyle = .none
    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MainEntryCell = contentTableView.dequeueReusableCell(withIdentifier: "MainEntryCellProfile") as! MainEntryCell
        cell.setCellProfile(post: posts[indexPath.row], tableView: contentTableView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

}
