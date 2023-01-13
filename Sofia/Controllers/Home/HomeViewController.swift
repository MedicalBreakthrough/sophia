//
//  HomeViewController.swift
//  Sofia
//
//  Created by Mac on 05/01/2023.
//

import UIKit
import SnapKit
import SideMenu
import HMSegmentedControl
import FirebaseDatabase

class HomeViewController: UIViewController {
    
    var userId = String()
    
    @IBOutlet weak var feedCollectionView: UICollectionView!
    
    @IBOutlet weak var navigiationView: UIView!
    
    //MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        userId = UserDefaults.standard.string(forKey: UserDetails.userId) ?? ""
        
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self
        
        setupSegmentControl()
    }
    
    //MARK:- viewWillAppear()
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @objc func segmentedControlChangedValue(segmentedControl: HMSegmentedControl)
    {
        if segmentedControl.selectedSegmentIndex == 0
        {
            print("Trending")
        }
        else
        {
            print("For you")
        }
    }
    
    //MARK:- menuBtnAct()
    @IBAction func sideMenuBtnAct(_ sender: UIButton)
    {
        let menu = storyboard!.instantiateViewController(withIdentifier: "RightMenu") as! SideMenuNavigationController
        present(menu, animated: true, completion: nil)
    }
    
    //MARK:- searchBtnAct()
    @IBAction func searchBtnAct(_ sender: UIButton)
    {
        
    }
    
    //MARK:- likeBtnAct()
    @IBAction func likeBtnAct(_ sender: UIButton)
    {
        print("Like Clicked")
    }
    
    //MARK:- saveBtnAct()
    @IBAction func saveBtnAct(_ sender: UIButton)
    {
        print("Save Clicked")
    }
    
    //MARK:- commentBtnAct()
    @IBAction func commentBtnAct(_ sender: UIButton)
    {
        print("Comment Clicked")
    }
    
    //MARK:- shareBtnAct()
    @IBAction func shareBtnAct(_ sender: UIButton)
    {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let textToShare = "Check out SOPHIA app"
        if let myWebsite = URL(string: "http://itunes.apple.com/app/idXXXXXXXXX")
        {
            let objectsToShare = [textToShare, myWebsite, image ?? UIImage(imageLiteralResourceName: "app-logo")] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    //MARK:- setupSegmentControl()
    func setupSegmentControl()
    {
        let segmentedControl = HMSegmentedControl(sectionTitles: ["Trending","For you"])
        let screenWidth = view.frame.width
//        segmentedControl.frame = CGRect(x: (screenWidth - 200) / 2, y: navigiationView.bounds.midY , width: 200, height: 40)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.navigiationView.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
//            segmentedControl.topAnchor.constraint(equalTo: navigiationView.bottomAnchor, constant: +20 ),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40.0),
            segmentedControl.widthAnchor.constraint(equalToConstant: 180),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: navigiationView.centerYAnchor)
        ])
//        segmentedControl.centerYAnchor.constraint(equalTo: self.navigiationView.centerYAnchor).isActive = true
        segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocation.bottom
        segmentedControl.backgroundColor = .clear
        segmentedControl.selectionIndicatorColor = .white
        segmentedControl.selectionIndicatorHeight = 2
        segmentedControl.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "ArialRoundedMTBold", size: 14)!, NSAttributedString.Key.foregroundColor: UIColor.white]
        segmentedControl.addTarget(self, action: #selector(segmentedControlChangedValue(segmentedControl:)), for: .valueChanged)
            //view.addSubview(segmentedControl)
    }
}

//MARK:- Collectionview delegates
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCollectionCell", for: indexPath) as! FeedCollectionCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return  UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0
    }
}

//MARK:- FeedCollectionCell
class FeedCollectionCell: UICollectionViewCell
{
    @IBOutlet weak var feedImageView: UIImageView!
}



//MARK:- Custom Segmented Control Code

//    @IBOutlet weak var homeTrendSegmentedControl: UISegmentedControl!
    
//    let segmentindicator: UIView = {
//    let v = UIView()
//    v.translatesAutoresizingMaskIntoConstraints = false
//    v.backgroundColor = UIColor.white
//    return v
//    }()


//        homeTrendSegmentedControl.backgroundColor = .clear
//        homeTrendSegmentedControl.tintColor = .clear
//
//        homeTrendSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "ArialRoundedMTBold", size: 14)!, NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
//        homeTrendSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "ArialRoundedMTBold", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        
//        self.view.addSubview(segmentindicator)
//        segmentindicator.snp.makeConstraints { (make) in
//        make.top.equalTo(homeTrendSegmentedControl.snp.bottom).offset(3)
//        make.height.equalTo(2)
//        make.width.equalTo(15 + homeTrendSegmentedControl.titleForSegment(at: 0)!.count * 8)
//        make.centerX.equalTo(homeTrendSegmentedControl.snp.centerX).dividedBy(2)
//        }


//MARK:- segmentValueChanged()
//    @IBAction func segmentValueChanged(_ sender: UISegmentedControl)
//    {
//       // let numberOfSegments = CGFloat(homeTrendSegmentedControl.numberOfSegments)
//        let selectedIndex = CGFloat(sender.selectedSegmentIndex)
//        let titlecount = CGFloat((homeTrendSegmentedControl.titleForSegment(at: sender.selectedSegmentIndex)!.count))
//        segmentindicator.snp.remakeConstraints { (make) in
//        make.top.equalTo(homeTrendSegmentedControl.snp.bottom).offset(3)
//            if selectedIndex == 0
//            {
//                make.leading.equalTo(homeTrendSegmentedControl.snp.leading)
//            }
//            else
//            {
//                make.trailing.equalTo(homeTrendSegmentedControl.snp.trailing)
//            }
//        make.height.equalTo(2)
//        make.width.equalTo(15 + titlecount * 8)
//        make.centerX.equalTo(homeTrendSegmentedControl.snp.centerX).dividedBy(2 / CGFloat(3.0 + CGFloat(selectedIndex-1.0)*2.0))
//        }
//        UIView.animate(withDuration: 0.5, animations: {
//        self.view.layoutIfNeeded() })
//    }
