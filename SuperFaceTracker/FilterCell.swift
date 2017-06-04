//
//  FilterCell.swift
//  SuperFaceTracker
//
//  Created by Angel Reyes on 04/06/17.
//  Copyright © 2017 Skylabs. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {

    @IBOutlet weak var filterImageView: UIImageView!
    
    
    var name:String? {
        didSet {
            filterImageView.image = UIImage(named: name!)
        }
    }
    

}
