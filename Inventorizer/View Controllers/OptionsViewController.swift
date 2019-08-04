//
//  SettingsViewController.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/23/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import UIKit
import UserNotifications

class OptionsViewController: UIViewController {

    @IBOutlet weak var notificationSlider: UISwitch!
    @IBOutlet weak var sendLabel: UILabel!
    @IBOutlet weak var pickerStack: UIStackView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableNameTextField: UITextField!
    @IBOutlet weak var yearLabel: UILabel!
    
    var table: Table!
    var parentTableVC: InventoryTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        datePicker.minimumDate = table.notification ?? Date()
        datePicker.date = datePicker.minimumDate!
        notificationSlider.setOn(!(table.notification == nil), animated: false)
        let _ = updateNotificationComponents()
        setYearLabel()
        tableNameTextField.text = table.name
    }
    
    @IBAction func notificationSliderChanged(_ sender: Any) {
        if updateNotificationComponents() {
            table.notification = datePicker.date
        }
        else {
            table.notification = nil
        }
    }
    
    func updateNotificationComponents() -> Bool {
        if notificationSlider.isOn {
            sendLabel.isHidden = false
            pickerStack.isHidden = false
            datePicker.isEnabled = true
            return true
        }
        else {
            sendLabel.isHidden = true
            pickerStack.isHidden = true
            datePicker.isEnabled = false
            return false
        }
    }
    
    @IBAction func textEdited(_ sender: Any) {
        table.name = tableNameTextField.text ?? ""
        parentTableVC.topNavigation.title = table.name

    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        setYearLabel()
        table.notification = datePicker.date
    }
    
    func setYearLabel() {
        yearLabel.text = "Year: \(datePicker.date.year())"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        CoreDataService.saveContext()
        if let notificationDate = table.notification {
            let content = UNMutableNotificationContent()
            content.title = "Time to check your stuff!"
            content.body = "Reminder to check your stuff in the table \(table.name)"
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: table.id.uuidString, content: content, trigger: trigger)
            
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request, withCompletionHandler: nil)
            
        }
        else {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [table.id.uuidString])
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

extension OptionsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
