//
//  ViewController.swift
//  SuperFaceTracker
//
//  Created by Angel Reyes on 28/05/17.
//  Copyright © 2017 Skylabs. All rights reserved.
//

import UIKit
import FaceTracker


class ViewController: UIViewController, FaceTrackerViewControllerDelegate, UICollectionViewDelegate, CircleMenuDelegate {
    
    
    
    @IBOutlet weak var faceTrackerContainerView: UIView!
    weak var faceTrackerViewController: FaceTrackerViewController?
    var puntos = [String: [UIView]]()
    var currentFilter = UIImageView()
    var currentFilterName:String!
    var twinkleTimer:Timer?
    var doTwinkle:Bool = false
    
    let filters = ["hat",
                   "moustache",
                   "glasses",
                   "beard",
                   "mask",
                   "tiger"]
    
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    let dataSource: FilterDataSource
    required init?(coder aDecoder: NSCoder) {
        self.dataSource = FilterDataSource(filters: self.filters)
        super.init(coder: aDecoder)
    }
    
    
    let items: [(icon: String, color: UIColor)] = [
        ("", UIColor.clear),
        ("", UIColor.clear),
        ("", UIColor.clear),
        ("", UIColor.clear),
        ("", UIColor.clear),
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibCollectionViewCell = UINib(nibName: "FilterCell", bundle: nil)
        filtersCollectionView.register(nibCollectionViewCell, forCellWithReuseIdentifier: "FilterCell")
        
        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = dataSource
        filtersCollectionView.reloadData()
        
        twinkleTimer = Timer.scheduledTimer(withTimeInterval: 1,
                                            repeats: true,
                                            block: { (t) in
                                                self.doTwinkle = true
                                            })
        
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
        photoCircleMenu.layer.cornerRadius = photoCircleMenu.frame.width/2
        
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
        self.currentFilter.isHidden = true
        for (_, views) in self.puntos {
            for view in views {
                view.isHidden = true
            }
        }
    }
    
    func setAnchorPoint(_ anchorPoint: CGPoint, forView view: UIView) {
        var newPoint = CGPoint(x: view.bounds.size.width * anchorPoint.x, y: view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: view.bounds.size.width * view.layer.anchorPoint.x, y: view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(view.transform)
        oldPoint = oldPoint.applying(view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
    func computeHatFilter(withPoints points:FacePoints) {
        let eyeCornerDist = sqrt(pow(points.leftEye[0].x - points.rightEye[5].x, 2) + pow(points.leftEye[0].y - points.rightEye[5].y, 2))
        let eyeToEyeCenter = CGPoint(x: (points.leftEye[0].x + points.rightEye[5].x) / 2, y: (points.leftEye[0].y + points.rightEye[5].y) / 2)
        
        let hatWidth = 2.0 * eyeCornerDist
        let hatHeight = (currentFilter.image!.size.height / currentFilter.image!.size.width) * hatWidth
        currentFilter.transform = CGAffineTransform.identity
        currentFilter.frame = CGRect(x: eyeToEyeCenter.x - hatWidth / 2, y: eyeToEyeCenter.y - 1.3 * hatHeight, width: hatWidth, height: hatHeight)
        currentFilter.isHidden = false
        setAnchorPoint(CGPoint(x: 0.5, y: 1.0), forView: currentFilter)
        let angle = atan2(points.rightEye[5].y - points.leftEye[0].y, points.rightEye[5].x - points.leftEye[0].x)
        currentFilter.transform = CGAffineTransform(rotationAngle: angle)
        if self.doTwinkle {
            self.doTwinkle = false
            DispatchQueue.main.async {
                self.currentFilter.twinkle()
            }
        }
        
    }
    
    func computeGlassesFilter(withPoints points:FacePoints) {
        let eyeCornerDist = sqrt(pow(points.leftEye[0].x - points.rightEye[5].x, 2) + pow(points.leftEye[0].y - points.rightEye[5].y, 2))
        let eyeToEyeCenter = CGPoint(x: (points.leftEye[0].x + points.rightEye[5].x) / 2, y: (points.leftEye[0].y + points.rightEye[5].y) / 2)
        
        let glassesWidth = eyeCornerDist * 1.7
        let glassesHeight = (currentFilter.image!.size.height / currentFilter.image!.size.width) * glassesWidth
        currentFilter.transform = CGAffineTransform.identity
        currentFilter.frame = CGRect(x: eyeToEyeCenter.x - glassesWidth / 2, y: eyeToEyeCenter.y - glassesHeight / 2, width: glassesWidth, height: glassesHeight)
        currentFilter.isHidden = false
        setAnchorPoint(CGPoint(x: 0.5, y: 1.0), forView: currentFilter)
        let angleGlasses = atan2(points.rightEye[5].y - points.leftEye[0].y, points.rightEye[5].x - points.leftEye[0].x)
        currentFilter.transform = CGAffineTransform(rotationAngle: angleGlasses)
    }
    
    func computeAntifazFilter(withPoints points:FacePoints) {
        let eyeCornerDist = sqrt(pow(points.leftEye[0].x - points.rightEye[5].x, 2) + pow(points.leftEye[0].y - points.rightEye[5].y, 2))
        let eyeToEyeCenter = CGPoint(x: (points.leftEye[0].x + points.rightEye[5].x) / 2, y: (points.leftEye[0].y + points.rightEye[5].y) / 2)
        
        let glassesWidth = eyeCornerDist * 1.7
        let glassesHeight = (currentFilter.image!.size.height / currentFilter.image!.size.width) * glassesWidth
        currentFilter.transform = CGAffineTransform.identity
        currentFilter.frame = CGRect(x: eyeToEyeCenter.x - glassesWidth / 2, y: eyeToEyeCenter.y - 0.8*glassesHeight, width: glassesWidth, height: glassesHeight)
        currentFilter.isHidden = false
        setAnchorPoint(CGPoint(x: 0.5, y: 1.0), forView: currentFilter)
        let angleGlasses = atan2(points.rightEye[5].y - points.leftEye[0].y, points.rightEye[5].x - points.leftEye[0].x)
        currentFilter.transform = CGAffineTransform(rotationAngle: angleGlasses)
        if self.doTwinkle {
            self.doTwinkle = false
            DispatchQueue.main.async {
                self.currentFilter.twinkle()
            }
        }
    }
    
    func computeMoustacheFilter(withPoints points:FacePoints) {
        let eyeCornerDist = sqrt(pow(points.leftEye[0].x - points.rightEye[5].x, 2) + pow(points.leftEye[0].y - points.rightEye[5].y, 2))
        
        let lipsNoseCenter = CGPoint(x: (points.leftEye[0].x + points.rightEye[5].x) / 2, y: (points.outerMouth[3].y + points.nose[3].y) / 2)
        let bigoteWidth = eyeCornerDist
        let bigoteHeight = (currentFilter.image!.size.height / currentFilter.image!.size.width) * bigoteWidth
        currentFilter.transform = CGAffineTransform.identity
        currentFilter.frame = CGRect(x: lipsNoseCenter.x - bigoteWidth / 2,
                              y: lipsNoseCenter.y - bigoteHeight*0.5,
                              width: bigoteWidth,
                              height: bigoteHeight)
        currentFilter.isHidden = false
        let angleGlasses = atan2(points.rightEye[5].y - points.leftEye[0].y, points.rightEye[5].x - points.leftEye[0].x)
        currentFilter.transform = CGAffineTransform(rotationAngle: angleGlasses)
    }
    
    func computeBeardFilter(withPoints points:FacePoints) {
        let eyeCornerDist = sqrt(pow(points.leftEye[0].x - points.rightEye[5].x, 2) + pow(points.leftEye[0].y - points.rightEye[5].y, 2))
        let mouthCenter = CGPoint(x: (points.outerMouth[0].x + points.outerMouth[6].x) / 2, y: (points.innerMouth[2].y + points.innerMouth[6].y) / 2)
        let barbaWidth = eyeCornerDist*1.5
        let barbaHeight = (currentFilter.image!.size.height / currentFilter.image!.size.width) * barbaWidth
        currentFilter.transform = CGAffineTransform.identity
        currentFilter.frame = CGRect(x: mouthCenter.x - barbaWidth / 2,
                             y: mouthCenter.y - barbaHeight*0.35,
                             width: barbaWidth,
                             height: barbaHeight)
        currentFilter.isHidden = false
        let angleBeard = atan2(points.rightEye[5].y - points.leftEye[0].y, points.rightEye[5].x - points.leftEye[0].x)
        currentFilter.transform = CGAffineTransform(rotationAngle: angleBeard)
    }
    
    func computePandaHead(withPoints points:FacePoints) {
        let eyeCornerDist = sqrt(pow(points.leftEye[0].x - points.rightEye[5].x, 2) + pow(points.leftEye[0].y - points.rightEye[5].y, 2))
        let headCenter = CGPoint(x: (points.leftEye[0].x + points.rightEye[5].x) / 2, y: points.nose[3].y)
        let headWidth = eyeCornerDist * 3
        let headHeight = (currentFilter.image!.size.height / currentFilter.image!.size.width) * headWidth
        currentFilter.transform = CGAffineTransform.identity
        currentFilter.frame = CGRect(x: headCenter.x - headWidth/2,
                             y: headCenter.y - headHeight/2.5,
                             width: headWidth,
                             height: headHeight)
        currentFilter.isHidden = false
        let angleTiger = atan2(points.rightEye[5].y - points.leftEye[0].y, points.rightEye[5].x - points.leftEye[0].x)
        currentFilter.transform = CGAffineTransform(rotationAngle: angleTiger)
    }
    
    func setFilter(_ name:String,_ points:FacePoints) {
        switch name {
        case "hat": computeHatFilter(withPoints: points); break
        case "glasses": computeGlassesFilter(withPoints: points); break
        case "mask": computeAntifazFilter(withPoints: points); break
        case "moustache": computeMoustacheFilter(withPoints: points); break
        case "beard": computeBeardFilter(withPoints: points); break
        case "tiger": computePandaHead(withPoints: points); break
        default: print("Unexpected Error!"); break
        }
    }
 
    
    func faceTrackerDidUpdate(_ points: FacePoints?) {
        if let points = points {
            
            /*
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
             */
            if currentFilterName != nil {
                setFilter(currentFilterName, points)
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
        currentFilterName = filters[indexPath.row]
        selectedItem(withImage: filters[indexPath.row])
    }
    
    
    // Mark - CircleMenuDelegate

    @IBOutlet weak var photoCircleMenu: CircleMenu!
    var isStopped:Bool = false
    @IBOutlet weak var bottomCollectionViewConstraint: NSLayoutConstraint!
    @IBAction func takePicture(_ sender: CircleMenu) {
        if isStopped {
            faceTrackerViewController!.startTracking { () -> Void in
                
            }
            UIView.animate(withDuration: 0.5, animations: {
                self.bottomCollectionViewConstraint.constant = 0
            })
        } else {
            
            faceTrackerViewController?.stopTracking() //.recievedFrame(image: UIImage, withPoints: [NSValue]?)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: { 
                    self.bottomCollectionViewConstraint.constant = -100
                    self.photoCircleMenu.isHidden = true
                }, completion: { (completed) in
                    UIGraphicsBeginImageContext(self.view.frame.size)
                    self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
                    let image = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
                    self.photoCircleMenu.isHidden = false
                })
            }
        }
        
        isStopped = !isStopped
        
    }
    
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        
        
        button.backgroundColor = UIColor.clear
        button.tintColor = UIColor.clear
        return
        /*
        guard atIndex == 0 || atIndex == 1 || atIndex == 4 else {
        }*/
        
        /*
        button.backgroundColor = items[atIndex].color
        button.setImage(UIImage(named: items[atIndex].icon), for: .normal)
        let highlightedImage  = UIImage(named: items[atIndex].icon)?.withRenderingMode(.alwaysTemplate)
        button.setImage(highlightedImage, for: .highlighted)
        button.tintColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
        */
        
    }
    
    
    
    func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
        print("button will selected: \(atIndex)")
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        print("button did selected: \(atIndex)")
    }

}

