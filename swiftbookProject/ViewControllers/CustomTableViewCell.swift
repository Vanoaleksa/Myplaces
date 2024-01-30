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
    
    let stackView = UIStackView()
    
    var imagesArr = [UIImageView]()
    
    var rating = 0 {
        didSet {
            updateStarState()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "Cell")
        
        setupCell()
        configureStackView()
        configureImageStar()
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
            nameLabel.widthAnchor.constraint(equalToConstant: 140),
            nameLabel.trailingAnchor.constraint(equalTo: imagePlace.trailingAnchor, constant: 280),
            
            locationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            locationLabel.leadingAnchor.constraint(equalTo: imagePlace.trailingAnchor, constant: 15),
            locationLabel.heightAnchor.constraint(equalToConstant: 21),
            locationLabel.widthAnchor.constraint(equalToConstant: 140),
            locationLabel.trailingAnchor.constraint(equalTo: imagePlace.trailingAnchor, constant: 280),

            
            typeLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5),
            typeLabel.leadingAnchor.constraint(equalTo: imagePlace.trailingAnchor, constant: 15 ),
            typeLabel.heightAnchor.constraint(equalToConstant: 21),
            typeLabel.widthAnchor.constraint(equalToConstant: 140),
            typeLabel.trailingAnchor.constraint(equalTo: imagePlace.trailingAnchor, constant: 280)

        ])
    }
    
    func configureStackView() {
        // Configure stack view
    
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
                
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 23),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.heightAnchor.constraint(equalToConstant: 15),
            stackView.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func configureImageStar() {
        for i in 0..<5 {
            
            let starImage = UIImageView()
            starImage.tag = i + 1
            starImage.image = (UIImage(named: "emptyStar"))
            starImage.translatesAutoresizingMaskIntoConstraints = false
            starImage.widthAnchor.constraint(equalToConstant: 13).isActive = true
            
            stackView.addArrangedSubview(starImage)
            imagesArr.append(starImage)
        }
        updateStarState()
    }
    
    func updateStarState() {
        for (index, star) in imagesArr.enumerated() {
            if index < rating {
                star.image = UIImage(named: "filledStar")
            } else {
                star.image = UIImage(named: "emptyStar")
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imagePlace.layer.cornerRadius = imagePlace.frame.size.height / 2
        imagePlace.clipsToBounds = true
    }
}

