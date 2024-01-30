//
//  CustomRatingControllCell.swift
//  swiftbookProject
//
//  Created by MacBook on 26.01.24.
//

import UIKit

class CustomRatingControllCell: UITableViewCell {

    let stackView = UIStackView()
    var buttons = [UIButton]()
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: "RatingCell")
        configureStackView()
        configureButtons()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureStackView() {
        // Configure stack view
    
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
                
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = buttons.firstIndex(of: button) else { return }
        
        // Calculate the rating of selected button
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
        
    }
    
    func configureButtons() {
        
        for i in 0..<5 {
            
            let button = UIButton()
            
            button.tag = i // Set tag as index
            button.setImage(UIImage(named: "emptyStar"), for: .normal)
            button.setImage(UIImage(named: "filledStar"), for: .selected)
            button.setImage(UIImage(named: "highlightedStar"), for: .highlighted)
            button.setImage(UIImage(named: "highlightedStar"), for: [.highlighted, .selected])
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
            button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
            
            button.addTarget(self, action: #selector(ratingButtonTapped(button: )), for: .touchUpInside)
        
            stackView.addArrangedSubview(button)
            buttons.append(button)
        }
        updateButtonSelectionState()
    }
    
    func updateButtonSelectionState() {
        for (index, button) in buttons.enumerated() {
            button.isSelected = index < rating
        }
    }
    
}
