//
//  SettingsViewController.swift
//  TwitterDemo
//
//  Created by Marat on 05/02/2017.
//  Copyright © 2017 Favio Mobile. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    static var showAvatarsKey = "showAvatars"
    
    @IBOutlet var showAvatarsSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let isOn = UserDefaults.standard.bool(forKey: SettingsViewController.showAvatarsKey)
        self.showAvatarsSwitch.isOn = isOn
    }
    
    @IBAction func showAvatarsChanged(sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: SettingsViewController.showAvatarsKey)
    }
    
    @IBAction func done(sender: UIControl) {
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: .showAvatarsChanged, object: nil)
        }
    }
}
