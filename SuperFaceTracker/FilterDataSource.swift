//
//  FilterDataSource.swift
//  SuperFaceTracker
//
//  Created by Angel Reyes on 04/06/17.
//  Copyright © 2017 Skylabs. All rights reserved.
//

import UIKit

class FilterDataSource: NSObject {
    let filters: [String]
    
    init(filters: [String]) {
        self.filters = filters
    }
}

extension FilterDataSource: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.name = filters[indexPath.row]
        cell.layer.cornerRadius = 10 //45 for circular approach
        return cell
    }
    
    
    
}
