//
//  SettingsViewController.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/23/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var notificationSlider: UISwitch!
    @IBOutlet weak var sendLabel: UILabel!
    @IBOutlet weak var pickerStack: UIStackView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        datePicker.minimumDate = Date()
        notificationSliderChanged(self)
    }
    
    @IBAction func notificationSliderChanged(_ sender: Any) {
        if (notificationSlider.isOn) {
            sendLabel.isHidden = false
            pickerStack.isHidden = false
            datePicker.isEnabled = true
            timePicker.isEnabled = true
        }
        else {
            sendLabel.isHidden = true
            pickerStack.isHidden = true
            datePicker.isEnabled = false
            timePicker.isEnabled = false
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
