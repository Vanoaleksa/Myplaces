//
//  CustomNewPlaceCell.swift
//  swiftbookProject
//
//  Created by MacBook on 9.01.24.
//

import UIKit

class CustomNewPlaceCell: UITableViewCell {
    
    var newLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Apple SD Gothic Neo", size: 20)
        label.textColor = .gray
        
        return label
    }()
    
    var newTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        
        return textField
    }()
    
    lazy var getAdressButton: UIButton = {
        let getAdressButton = UIButton()
        getAdressButton.setImage(UIImage(named: "Placeholder"), for: .normal)
        getAdressButton.isHidden = true
        
        return getAdressButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "Cell")
         
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell() {
        [newLabel, newTextField, getAdressButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            newLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            newLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 16),
            newLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            newLabel.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: 55),
            
            newTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            newTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 16),
            newTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            getAdressButton.heightAnchor.constraint(equalToConstant: 22),
            getAdressButton.widthAnchor.constraint(equalToConstant: 22),
            getAdressButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -17),
            getAdressButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }

}

extension CustomNewPlaceCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
