//
//  NewPlaceViewController.swift
//  swiftbookProject
//
//  Created by MacBook on 9.01.24.
//

import UIKit
import RealmSwift

class NewPlaceViewController: UITableViewController {
    
    var newImage = UIImage(named: "Photo")
    var newPlace = Place()
    var currentPlace: Place?
    
    weak var delegate: NewPlaceDelegate?
    var imageIsChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureNavBarController()
        createTableView()
        setupEditScreen()
    }
    
    private func createTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(CustomImageNewPlaceCell.self, forCellReuseIdentifier: "CellImage")
        tableView.register(CustomNewPlaceCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(CustomRatingControllCell.self, forCellReuseIdentifier: "RatingCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .darkGray
    }
}

// MARK: - Table view data source
extension NewPlaceViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RatingCell", for: indexPath) as! CustomRatingControllCell
            if currentPlace != nil {
                cell.rating = Int(currentPlace!.rating)
            }
                
            return cell
        }
        
        if indexPath.row == 0 {
            let imageCell = tableView.dequeueReusableCell(withIdentifier: "CellImage", for: indexPath) as! CustomImageNewPlaceCell
            imageCell.imageNewPlace.image = newImage
            
            if currentPlace != nil {
                imageCell.imageNewPlace.contentMode = .scaleAspectFill
            }
            
            imageCell.openMapButton.addTarget(self, action: #selector(actionMapButton), for: .touchUpInside)
            
            return imageCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomNewPlaceCell
            if indexPath.row == 1 {
                cell.newLabel.text = "Name"
                cell.newTextField.placeholder = "Place Name"
                cell.newTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
                cell.newTextField.text = newPlace.name

            } else if indexPath.row == 2 {
                cell.newLabel.text = "Type"
                cell.newTextField.placeholder = "Place Type"
                cell.newTextField.text = newPlace.type ?? ""

            } else if indexPath.row == 3 {
                cell.newLabel.text = "Location"
                cell.newTextField.placeholder = "Place Location"
                cell.newTextField.text = newPlace.location ?? ""
                cell.getAdressButton.isHidden = false
                cell.getAdressButton.addTarget(self, action: #selector(getAdress), for: .touchUpInside)

            }
            cell.newTextField.delegate = cell
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    @objc func getAdress() {
        let mapController = MapViewController()
        mapController.incomeIdentifier = "getAddress"
        mapController.mapViewControllerDelegate = self
        
        navigationController?.pushViewController(mapController, animated: true)
    }
    
    func setupEditScreen() {
        guard let place = currentPlace else { return }
        
        title = place.name
        
        newImage = UIImage(data: place.image ?? Data()) ?? UIImage(named: "Photo")
            
        imageIsChanged = true
            
        newPlace = place
            
        navigationItem.rightBarButtonItem?.isEnabled = true
                  
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let cameraIcon = UIImage(named: "camera")
            let photoIcon = UIImage(named: "photoIcon")
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")

            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
}

// MARK: - configureNavBarController
extension NewPlaceViewController {
    
    private func configureViewController() {
        title = "New Place"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:
                                                                    UIFont(name: "Avenir", size: 20) as Any
        ]
    }
    
    private func configureNavBarController() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                                 style: .done,
                                                                 target: self,
                                                                 action: #selector(actionSaveButton))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        
        
    }
    
    @objc func actionSaveButton(_ sender: UIBarButtonItem) {
        var name = ""
        var type = ""
        var location = ""
        let image = imageIsChanged ? newImage : UIImage(named: "imagePlaceholder")
        let imageData = image?.pngData()
        var rating = 0.0
           
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CustomNewPlaceCell {
                name = cell.newTextField.text!
            }
        if let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? CustomNewPlaceCell {
                type = cell.newTextField.text ?? ""
            }
        if let cell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? CustomNewPlaceCell {
                location = cell.newTextField.text ?? ""
            }
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? CustomRatingControllCell {
            rating = Double(cell.rating)
        }
        
//         Создаем новый экземпляр Place и заполняем его свойства значениями из текстовых полей
        
        let newPlace = Place(name: name,location: location, type: type, image: imageData, rating: rating)
        
        if currentPlace != nil {
            try! realm.write ({
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.image = newPlace.image
                currentPlace?.rating = newPlace.rating
                delegate?.didAddNewPlace(newPlace)
            })
            
        } else {
                StorageManager.saveObject(newPlace)
                delegate?.didAddNewPlace(newPlace)
        }

        navigationController?.popViewController(animated: true)
    }
}

//MARK: Work with image
extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        newImage = info[.editedImage] as? UIImage
        dismiss(animated: true)
        
        imageIsChanged = true
        
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
}

//MARK: - UITableViewDelegate
extension NewPlaceViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 4 {
            return 140
        }
        if indexPath.row == 0 {
            return 250
        } else {
            return 85.0
        }
    }
}

//MARK: - Work with empty textfield
extension NewPlaceViewController {
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.superview?.superview is CustomNewPlaceCell {
            if textField.text?.isEmpty == false {
                navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
    }
}

protocol NewPlaceDelegate: NSObject {
    func didAddNewPlace(_ place: Place)
}

extension NewPlaceViewController {
    //Action mapButton
    
    @objc func actionMapButton() {
        let mapController = MapViewController()
        
        var name = ""
        var type = ""
        var location = ""
        let image = imageIsChanged ? newImage : UIImage(named: "imagePlaceholder")
        var rating = 0.0
           
        let imageData = image?.pngData()
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CustomNewPlaceCell {
                name = cell.newTextField.text!
            }
        if let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? CustomNewPlaceCell {
                type = cell.newTextField.text ?? ""
            }
        if let cell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? CustomNewPlaceCell {
                location = cell.newTextField.text ?? ""
            }
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? CustomRatingControllCell {
            rating = Double(cell.rating)
        }
        
//         Создаем новый экземпляр Place и заполняем его свойства значениями из текстовых полей
        
        let currentPlace = Place(name: name,location: location, type: type, image: imageData, rating: rating)
        
        mapController.place = currentPlace
        mapController.incomeIdentifier = "showPlace"
        
        navigationController?.pushViewController(mapController, animated: true)
    }
}

extension NewPlaceViewController: MapViewControllerDelegate {
    func getAddress(_ address: String?) {
        if currentPlace != nil {
            try! realm.write{
                currentPlace?.location = address
            }
        } else {
            try! realm.write {
                newPlace.location = address
            }
        }
        
        tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
    }
}








