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
    private var places: Results<Place>!
    private var filteredPlaces: Results<Place>!
    var editingPlace = Place()
    private var segmentControll = UISegmentedControl()
    private var ascendingSorting = true
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIssEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false}
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIssEmpty
    }
//    weak var delegate: EditPlaceDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
        configureNavController()
        configureSearchController()
        configureBarButton()
        configureSegmentControll()
        createTableView()
        createLeftBarButton()
        setConstraints()
    }
    
    private func createTableView() {
        tableViewController.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableViewController.tableView.delegate = self
        tableViewController.tableView.dataSource = self
        tableViewController.tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableViewController.tableView)
    }
}

//MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPlaces.count
        }
        return places.isEmpty ? 0 : places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        var place = Place()
        
        if isFiltering {
            place = filteredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imagePlace.image = UIImage(data: place.image!)
//        place.rating = 0.0
        
        
        return cell
    } 
}

//MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate  {
    
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
        nextController.delegate = self
        let place: Place
        if isFiltering {
            place = filteredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }
//        let selectedPlace = places[indexPath.row]
        nextController.currentPlace = place
//        delegate?.editPlace(selectedPlace)
        navigationController?.pushViewController(nextController, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    }

//MARK: - configureBarButtons
extension ViewController {
    
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
    
    func createLeftBarButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "AZ"),
                                                           style: .done, target: self,
                                                           action: #selector(actionLeftBarButton))
    }
    
    @objc func actionLeftBarButton() {
        ascendingSorting.toggle()
        
        if ascendingSorting {
            navigationItem.leftBarButtonItem?.image = UIImage(named: "AZ")
        } else {
            navigationItem.leftBarButtonItem?.image = UIImage(named: "ZA")
        }
        
        sorting()
    }
    
}

extension ViewController {
    func configureSegmentControll() {
        let itemsArr = ["Date", "Name"]
        
        segmentControll = UISegmentedControl(items: itemsArr)
        segmentControll.translatesAutoresizingMaskIntoConstraints = false
        segmentControll.selectedSegmentTintColor = #colorLiteral(red: 0.3933262595, green: 0.4401346216, blue: 1, alpha: 1)
        segmentControll.selectedSegmentIndex = 0
        segmentControll.addTarget(self, action: #selector(sortSelection), for: .valueChanged)
        
        view.addSubview(segmentControll)
    }
    
    @objc func sortSelection(_ sender: UISegmentedControl) {
        
        sorting()
    }
}

//MARK: - Sorting
extension ViewController {
    func sorting() {
        
        if segmentControll.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        tableViewController.tableView.reloadData()
    }
}




//MARK: - NewPlaceDelegate
extension ViewController: NewPlaceDelegate {
    
    func didAddNewPlace(_ place: Place) {
        tableViewController.tableView.reloadData()
    }
}

//MARK: - Configure search controller
extension ViewController {
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

//protocol EditPlaceDelegate: NSObject {
//    func editPlace(_ place: Place)
//}


extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableViewController.tableView.reloadData()
    }
}

//MARK: - SetConstraints
extension ViewController {
    func setConstraints() {
        NSLayoutConstraint.activate([
            segmentControll.topAnchor.constraint(equalTo: view.topAnchor),
            segmentControll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentControll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentControll.heightAnchor.constraint(equalToConstant: 30),
            segmentControll.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            
            tableViewController.tableView.topAnchor.constraint(equalTo: segmentControll.bottomAnchor),
            tableViewController.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewController.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableViewController.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
        ])
    }

}




