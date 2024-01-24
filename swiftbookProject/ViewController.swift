//
//  ViewController.swift
//  swiftbookProject
//
//  Created by MacBook on 5.01.24.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    var tableViewController = UITableViewController(style: .plain)
    var places: Results<Place>!
    var editingPlace = Place()
//    weak var delegate: EditPlaceDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
        configureNavController()
        createTableView()
        configureBarButton()
    }
    
    private func createTableView() {
        tableViewController.tableView = UITableView(frame: view.bounds, style: .plain)
        tableViewController.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableViewController.tableView.delegate = self
        tableViewController.tableView.dataSource = self

        view.addSubview(tableViewController.tableView)
    }
}

extension ViewController: UITableViewDataSource {
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imagePlace.image = UIImage(data: place.image!)
        
        return cell
    } 
}

extension ViewController: UITableViewDelegate  {
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
    
    internal func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = places[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let swipeAcion = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return swipeAcion
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextController = NewPlaceViewController()
//        tableView.delegate = self
        let selectedPlace = places[indexPath.row]
        nextController.currentPlace = selectedPlace
//        delegate?.editPlace(selectedPlace)
        navigationController?.pushViewController(nextController, animated: true)
    }
    }


extension ViewController {
    //MARK: - configureBarButton
    
    private func configureNavController() {
        title = "My places"
        self.edgesForExtendedLayout = []
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:
                                                                    UIFont(name: "SnellRoundhand-Bold",
                                                                           size: 30) as Any
            ]
        }
    
    @objc private func configureBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .add,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector (actionBarButton))
    }
    
    @objc private func actionBarButton() {
        let nextController = NewPlaceViewController()
        nextController.delegate = self
        
        navigationController?.pushViewController(nextController, animated: true)
    }
}


//MARK: - NewPlaceDelegate
extension ViewController: NewPlaceDelegate {
    func didAddNewPlace(_ place: Place) {
        tableViewController.tableView.reloadData()
    }
}

//protocol EditPlaceDelegate: NSObject {
//    func editPlace(_ place: Place)
//}




