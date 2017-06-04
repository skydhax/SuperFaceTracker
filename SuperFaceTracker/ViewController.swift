//
//  ViewController.swift
//  SuperFaceTracker
//
//  Created by Angel Reyes on 28/05/17.
//  Copyright © 2017 Skylabs. All rights reserved.
//

import UIKit
import FaceTracker

class ViewController: UIViewController, FaceTrackerViewControllerDelegate, UICollectionViewDelegate {
    
    
    
    @IBOutlet weak var faceTrackerContainerView: UIView!
    weak var faceTrackerViewController: FaceTrackerViewController?
    var puntos = [String: [UIView]]()
    var currentFilter = UIImageView()
    var currentFilterName:String!
    
    let filters = ["bigote",
                   "bigote",
                   "bigote",
                   "bigote",
                   "bigote",
                   "bigote",
                   "bigote",
                   "bigote",
                   "bigote",
                   "bigote",
                   "bigote"]
    
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    let dataSource: FilterDataSource
    required init?(coder aDecoder: NSCoder) {
        self.dataSource = FilterDataSource(filters: self.filters)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibCollectionViewCell = UINib(nibName: "FilterCell", bundle: nil)
        filtersCollectionView.register(nibCollectionViewCell, forCellWithReuseIdentifier: "FilterCell")
        
        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = dataSource
        filtersCollectionView.reloadData()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "faceTrackerSegue") {
            faceTrackerViewController = segue.destination as? FaceTrackerViewController
            faceTrackerViewController?.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        faceTrackerViewController!.startTracking { () -> Void in
            
        }
        
    }
    
    
    func updateViewForFeature(_ feature: String, _ index: Int, _ point:CGPoint, _ bgColor: UIColor) {
        
        let frame = CGRect(x: point.x-2, y: point.y-2, width: 4.0, height: 4.0)
        
        if self.puntos[feature] == nil {
            self.puntos[feature] = [UIView]()
        }
        
        if index < self.puntos[feature]!.count {
            self.puntos[feature]![index].frame = frame
            self.puntos[feature]![index].isHidden = false
            self.puntos[feature]![index].backgroundColor = bgColor
        } else {
            let newView = UIView(frame: frame)
            newView.backgroundColor = bgColor
            newView.isHidden = false
            self.view.addSubview(newView)
            self.puntos[feature]! += [newView]
        }
        
    }
    
    func hideAllOverlayViews() {
        for (_, views) in self.puntos {
            for view in views {
                view.isHidden = true
            }
        }
    }
    
    /*
    func setFilter(_ name:String,_ points:FacePoints) {
        switch name {
        case "hat": computeHatFilter(withPoints: points); break
        case "glasses": computeGlassesFilter(withPoints: points); break
        case "antifaz": computeAntifazFilter(withPoints: points); break
        case "moustache": computeMoustacheFilter(withPoints: points); break
        case "beard": computeBeardFilter(withPoints: points); break
        case "panda": computePandaHead(withPoints: points); break
        default: print("Unexpected Error!"); break
        }
    }
    */
    
    func faceTrackerDidUpdate(_ points: FacePoints?) {
        if let points = points {
            
            for(index, point) in points.leftEye.enumerated() {
                self.updateViewForFeature("leftEye", index, point, UIColor.blue)
            }
            for(index, point) in points.rightEye.enumerated() {
                self.updateViewForFeature("rightEye", index, point, UIColor.blue)
            }
            for(index, point) in points.leftBrow.enumerated() {
                self.updateViewForFeature("leftBrow", index, point, UIColor.white)
            }
            for(index, point) in points.rightBrow.enumerated() {
                self.updateViewForFeature("rightBrow", index, point, UIColor.white)
            }
            for(index, point) in points.nose.enumerated() {
                self.updateViewForFeature("nose", index, point, UIColor.yellow)
            }
            for(index, point) in points.innerMouth.enumerated() {
                self.updateViewForFeature("innerMouth", index, point, UIColor.red)
            }
            for(index, point) in points.outerMouth.enumerated() {
                self.updateViewForFeature("outerMouth", index, point, UIColor.orange)
            }
            if currentFilterName != nil {
                //setFilter(currentFilterName, points)
            }
            
        } else {
            self.hideAllOverlayViews()
        }
    }
    
    
    func selectedItem(withImage imageName:String) {
        self.view.insertSubview(currentFilter, aboveSubview: faceTrackerContainerView)
        currentFilter.image = UIImage(named: imageName)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Se ha seleccionado la celda: \(indexPath.row)")
        currentFilterName = filters[indexPath.row]
        selectedItem(withImage: filters[indexPath.row])
    }


}

