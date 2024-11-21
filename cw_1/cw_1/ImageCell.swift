//
//  ImageCell.swift
//  cw_1
//
//  Created by Кирилл Титов on 21.11.2024.
//

import UIKit

class ImageCell: UICollectionViewCell {
    var imageView: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Настройка UIImageView
        imageView = UIImageView(frame: bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        // Настройка UIActivityIndicatorView
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .gray
        activityIndicator.center = contentView.center
        activityIndicator.hidesWhenStopped = true
        contentView.addSubview(activityIndicator)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(with image: UIImage?) {
        imageView.image = image
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}
