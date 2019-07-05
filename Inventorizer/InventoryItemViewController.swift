//
//  InventoryItemViewController.swift
//  Inventorizer
//
//  Created by Kevin Traw Jr on 7/3/19.
//  Copyright © 2019 Kevin Traw Jr. All rights reserved.
//

import UIKit
import MobileCoreServices

class InventoryItemViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var accountedForSwitch: UISwitch!
    
    var currentItem: InventoryItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let unpackCurrentItem = currentItem {
            nameTextField.text = unpackCurrentItem.name
            categoryTextField.text = unpackCurrentItem.category
            accountedForSwitch.setOn(unpackCurrentItem.accountedFor, animated: false)
            
            if let unpackImage = unpackCurrentItem.image {
                itemImageView.image = unpackImage
            }
        }
    }
    
    // UITextFieldDelegate func
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // UIImagePickerControllerDelegate func
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? NSString
        if mediaType == kUTTypeImage {
            itemImageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
    }
    
    @IBAction func addPhotoTapped(_ sender: Any) {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        
        let sourceAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sourceAlert.addAction(UIAlertAction(title: "Take Photo", style: UIAlertAction.Style.default, handler: {(_) in
                imgPicker.sourceType = .camera
                self.present(imgPicker, animated: true, completion: nil)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            sourceAlert.addAction(UIAlertAction(title: "Choose Photo", style: UIAlertAction.Style.default, handler: {(_) in
                imgPicker.sourceType = .photoLibrary
                self.present(imgPicker, animated: true, completion: nil)
            }))
        }
        
        sourceAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(sourceAlert, animated: true, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }*/
    

}
