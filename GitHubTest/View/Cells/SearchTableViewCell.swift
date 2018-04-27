//
//  SearchTableViewCell.swift
//  GitHubTest
//
//  Created by Roman Syrota on 31.03.2018.
//  Copyright © 2018 Roman Syrota. All rights reserved.
//

import UIKit

protocol SearchTableViewCellDelegate: class {
    func addObjectToFavorites(repository: Repository)
    func deleteObjectFromFavorites(repository: Repository)
}

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var repoNameLabel: UILabel!
    @IBOutlet weak var repoStarsLabel: UILabel!
    @IBOutlet weak var favotiteButton: UIButton!
    var repository: Repository!
    var isFavorite = false
    weak var delegate: SearchTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //MARK: - Actions
    
    @IBAction func addToFavoritesAction(_ sender: UIButton) {
        if isFavorite {
            sender.setImage(UIImage(named: "notFavorites.png"), for: .normal)
            self.delegate?.deleteObjectFromFavorites(repository: repository)
        } else {
            sender.setImage(UIImage(named: "Favorites.png"), for: .normal)
            self.delegate?.addObjectToFavorites(repository: repository)
        }
        isFavorite = !isFavorite
    }
    
}
