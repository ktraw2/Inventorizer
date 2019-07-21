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
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var accountedForSwitch: UISwitch!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var topNavBar: UINavigationItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    var incomingData: CDCategorizedItem?
    var masterDataSource: InventorizerTableViewDataSource?
    
    var editMode = true
    
    private static let storyboardIdentifier = "Main"
    private static let selfIdentifier = "InventoryItemViewController"
    
    class func buildItemControllerWith(_ incomingData: CDCategorizedItem?) -> InventoryItemViewController? {
        let storyboard = UIStoryboard(name: storyboardIdentifier, bundle: nil)
        guard let itemViewController = storyboard.instantiateViewController(withIdentifier: selfIdentifier) as? InventoryItemViewController else {
            return nil
        }
        
        itemViewController.incomingData = incomingData
        
        return itemViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // load item information
        if let unpackIncomingData = incomingData {
            nameTextField.text = unpackIncomingData.item.name
            categoryTextField.text = unpackIncomingData.item.category.name
            notesTextView.text = unpackIncomingData.item.notes
            accountedForSwitch.setOn(unpackIncomingData.item.accountedFor, animated: false)
            
            if let unpackImage = unpackIncomingData.item.image {
                // TODO: Images
                Utilities.updateImage(for: itemImageView, with: nil)
            }
            else {
                Utilities.updateImage(for: itemImageView, with: Utilities.defaultPlaceholderImage)
            }
            
            // modify the top bar, change title and buttons
            topNavBar.title = unpackIncomingData.item.name
            setEditMode(false)
        }
        else {
            Utilities.updateImage(for: itemImageView, with: Utilities.defaultPlaceholderImage)
        }
        
        // give notesTextView a border
        notesTextView.layer.cornerRadius = 5
        notesTextView.layer.borderWidth = 0.25
        notesTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        let doneToolbar = UIToolbar()
        doneToolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.donePressed))
        doneToolbar.setItems([flexSpace, doneButton], animated: false)
        
        // add the toolbar to all 3 text boxes
        notesTextView.inputAccessoryView = doneToolbar
        nameTextField.inputAccessoryView = doneToolbar
        categoryTextField.inputAccessoryView = doneToolbar
        
        // register notifications to be able to resize the UIScrollView
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardRectangle = keyboardInfo.cgRectValue
        mainScrollView.contentInset.bottom = keyboardRectangle.size.height + 10
        mainScrollView.scrollIndicatorInsets.bottom = keyboardRectangle.size.height + 10
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        mainScrollView.contentInset.bottom = 0
        mainScrollView.scrollIndicatorInsets.bottom = 0
    }
    
    @objc func donePressed() {
        view.endEditing(true)
    }
    
    @objc func editPressed() {
        setEditMode(true)
    }
    
    func setEditMode(_ editMode: Bool) {
        self.editMode = editMode
        
        nameTextField.isEnabled = editMode
        categoryTextField.isEnabled = editMode
        notesTextView.isEditable = editMode
        notesTextView.isSelectable = editMode
        accountedForSwitch.isEnabled = editMode
        
        if editMode {
            topNavBar.setLeftBarButton(cancelButton, animated: true)
            topNavBar.setRightBarButton(saveButton, animated: true)
        }
        else {
            topNavBar.setLeftBarButton(nil, animated: true)
            let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
            topNavBar.setRightBarButton(editButton, animated: true)
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
            Utilities.updateImage(for: itemImageView, with: info[UIImagePickerController.InfoKey.originalImage] as? UIImage)
        }
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        guard let dataSource = masterDataSource else {
            return
        }
        
        dataSource.updateTable(fromDataIn: self, doIfSuccessful: {
            self.performSegue(withIdentifier: "CloseItem", sender: self)
        })
    }
    
    @IBAction func photoTapped(_ sender: UITapGestureRecognizer) {
        // only allow editing of photo if we are in edit mode
        if editMode == false {
            return
        }
        
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        
        let sourceAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        // code for iPads
        sourceAlert.popoverPresentationController?.sourceView = itemImageView
        sourceAlert.popoverPresentationController?.sourceRect = CGRect(x: sender.location(in: itemImageView).x, y: sender.location(in: itemImageView).y, width: 0, height: 0)
        
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
    
    @IBAction func photoLongPressed(_ sender: UITapGestureRecognizer) {
        // only allow editing of photo if we are in edit mode
        if editMode == false {
            return
        }
        
        guard let image = itemImageView.image else {
            return
        }
        if image == Utilities.defaultPlaceholderImage {
            return
        }
        
        let extraOptionsAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // code for iPads
        extraOptionsAlert.popoverPresentationController?.sourceView = itemImageView
        extraOptionsAlert.popoverPresentationController?.sourceRect = CGRect(x: sender.location(in: itemImageView).x, y: sender.location(in: itemImageView).y, width: 0, height: 0)
        
        extraOptionsAlert.addAction(UIAlertAction(title: "Save to Camera Roll", style: .default, handler: {(_) in
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }))
        
        extraOptionsAlert.addAction(UIAlertAction(title: "Delete Photo", style: .destructive, handler: {(_) in
            let confirmDeleteAlert = UIAlertController(title: "Are you sure you want to delete the photo?", message: "You can undo this action later by selecting \"Cancel\"", preferredStyle: .alert)
            
            confirmDeleteAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {(_) in
                Utilities.updateImage(for: self.itemImageView, with: Utilities.defaultPlaceholderImage)
                
            }))
            
            confirmDeleteAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present(confirmDeleteAlert, animated: true)
        }))
        
        extraOptionsAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(extraOptionsAlert, animated: true)
    }
}
