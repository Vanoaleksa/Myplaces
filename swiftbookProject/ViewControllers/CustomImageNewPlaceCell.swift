//
//  CustomImageNewPlaceCell.swift
//  swiftbookProject
//
//  Created by MacBook on 11.01.24.
//

import UIKit

public class CustomImageNewPlaceCell: UITableViewCell {

    public var imageNewPlace = UIImageView()
    var openMapButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "CellImage")
        
        configureImagePlaceView()
        configureMapButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureImagePlaceView() {
        imageNewPlace.translatesAutoresizingMaskIntoConstraints = false
        imageNewPlace.backgroundColor = .gray
        imageNewPlace.contentMode = .center
        imageNewPlace.clipsToBounds = true
        
        contentView.addSubview(imageNewPlace)
        
        NSLayoutConstraint.activate([
            imageNewPlace.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageNewPlace.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageNewPlace.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageNewPlace.heightAnchor.constraint(equalToConstant: 250),
            imageNewPlace.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configureMapButton() {
        openMapButton.translatesAutoresizingMaskIntoConstraints = false
        openMapButton.setImage(UIImage(named: "map"), for: .normal)
        
        contentView.addSubview(openMapButton)
        
        NSLayoutConstraint.activate([
            openMapButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            openMapButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            openMapButton.widthAnchor.constraint(equalToConstant: 50),
            openMapButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}




