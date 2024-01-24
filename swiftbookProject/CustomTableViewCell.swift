//
//  CustomTableViewCell.swift
//  swiftbookProject
//
//  Created by MacBook on 7.01.24.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    var imagePlace = UIImageView()
    
    var nameLabel: UILabel = {
        let label = UILabel() 
        label.font = UIFont.systemFont(ofSize: 18)
                
        return label
    }()
    
    var locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "Location"
        
        return label
    }()
    
    var typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "Type"

        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "Cell")
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        
        [imagePlace, nameLabel, locationLabel, typeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
                
        NSLayoutConstraint.activate([
            imagePlace.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imagePlace.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            imagePlace.heightAnchor.constraint(equalToConstant: 65),
            imagePlace.widthAnchor.constraint(equalToConstant: 65),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
            nameLabel.leadingAnchor.constraint(equalTo: imagePlace.trailingAnchor, constant: 15),
            nameLabel.heightAnchor.constraint(equalToConstant: 21),
            nameLabel.widthAnchor.constraint(equalToConstant: 264),
            
            locationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            locationLabel.leadingAnchor.constraint(equalTo: imagePlace.trailingAnchor, constant: 15),
            locationLabel.heightAnchor.constraint(equalToConstant: 21),
            locationLabel.widthAnchor.constraint(equalToConstant: 264),
            
            typeLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5),
            typeLabel.leadingAnchor.constraint(equalTo: imagePlace.trailingAnchor, constant: 15 ),
            typeLabel.heightAnchor.constraint(equalToConstant: 21),
            typeLabel.widthAnchor.constraint(equalToConstant: 264),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imagePlace.layer.cornerRadius = imagePlace.frame.size.height / 2
        imagePlace.clipsToBounds = true
    }
}

