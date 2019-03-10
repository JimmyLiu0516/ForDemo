//
//  SearchResultCollectionViewCell.swift
//  ForDemo
//
//  Created by Blacktea Liu on 2019/3/11.
//  Copyright © 2019 Jimmy Liu. All rights reserved.
//

import UIKit

class SearchResultCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var isFavorite: Bool = false {
        didSet {
            if isFavorite {
                self.favoriteButton.setTitle("已收藏", for: .normal)
            }
            else {
                self.favoriteButton.setTitle("收藏", for: .normal)
            }
        }
    }
    
    var favoriteHandler: ((_ isFavorite: Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.contentMode = .scaleAspectFit
    }
    
    @IBAction func favoriteAction(_ sender: Any) {
        if self.isFavorite {
            self.isFavorite = false
        }
        else {
            self.isFavorite = true
        }
        
        if let handler = self.favoriteHandler {
            handler(self.isFavorite)
        }
    }
}
