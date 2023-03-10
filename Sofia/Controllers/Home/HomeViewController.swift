//
//  HomeViewController.swift
//  Sofia
//
//  Created by Mac on 05/01/2023.
//

import UIKit
import SnapKit
import SideMenu
import Kingfisher
import HMSegmentedControl
import FirebaseDatabase



class HomeViewController: UIViewController {

   
    
    var userId = String()
    
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var feedCollectionView: UICollectionView!
    @IBOutlet weak var navigiationView: UIView!
    var userName = ""
    var feedList = [FeedModel]()
    var unSortDateList = [String]()
    var userProfileImage = UIImage()
    //MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
  
        noDataView.isHidden = true
        setupSegmentControl()
    }
    
    //MARK:- viewWillAppear()
    override func viewWillAppear(_ animated: Bool) {
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self
        self.userProfileImage = UIImage(named: "ProfileDefultImage")!
        userId = UserDefaults.standard.string(forKey: UserDetails.userId) ?? ""
        getUserDetails(userID: userId)

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
    @objc func shareBtnAct(_ sender: UIButton)
    {
        let currentFeed = feedList[sender.tag]
        let textToShare = "Check out SOPHIA app"
        if let link = NSURL(string: currentFeed.feedImage)
        {
            let objectsToShare = [textToShare,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    //MARK:- downloadBtnAct()
    @objc func downloadBtnAct(_ sender: UIButton)
    {
        let currentFeed = feedList[sender.tag]
        if let url = URL(string: currentFeed.feedImage) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    let image = UIImage(data: imageData)!
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    self.showToast(message: "Successfully downloaded")
                }
            }.resume()
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
    
    //MARK:- getItemsList()
    func getItemsList(userID : String)
    {
        feedList.removeAll()
        unSortDateList.removeAll()
        let ref = Database.database(url: "https://sofia-67890-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
        ref.child("users").child(userID).child("feedList").getData(completion:  { [self] error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            let value = snapshot?.value as? NSDictionary
            if value?.count ?? 0 > 0
            {
                self.noDataView.isHidden = true
                for oneFeed in value!
                {
                    let currentFeed = oneFeed.value as! [String:Any]
                    let currentImage = currentFeed["feedImage"] as? String ?? ""
                    let currentDate = currentFeed["date"] as? String ?? ""
                    let currentText = currentFeed["textDesc"] as? String ?? ""
                    let userName = currentFeed["name"] as? String ?? ""
                    let oneItem = FeedModel.init(userName: userName, feedText: currentText, feedDate: currentDate, feedImage: currentImage)
                    self.feedList.append(oneItem)
                    self.unSortDateList.append(currentDate)
                }
                sort()
            }
            else
            {
                self.noDataView.isHidden = false
            }
        })
    }
    
    //MARK:- sort()
    func sort()
    {
        var convertedArray: [Date] = []
        var sortedDatesList = [String]()
        var sortedFeedList = [FeedModel]()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
        for dat in unSortDateList {
            let date = dateFormatter.date(from: dat)
            if let date = date {
                convertedArray.append(date)
            }
        }
        let ready = convertedArray.sorted(by: { $0.compare($1) == .orderedDescending })
        for dat in ready {
            let dateStr = dateFormatter.string(from: dat)
            sortedDatesList.append(dateStr)
        }
        
        for oneDate in sortedDatesList
        {
            for i in 0...sortedDatesList.count-1
            {
                if oneDate == feedList[i].feedDate
                {
                    sortedFeedList.append(feedList[i])
                }
            }
        }
        feedList = sortedFeedList
        self.feedCollectionView.reloadData()
    }
    
    //MARK:- getUserDetails()
    func getUserDetails(userID : String)
    {
        let ref = Database.database(url: "https://sofia-67890-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
        ref.child("users").child(userID).child("userDetails").getData(completion:  { [self] error, snapshot in
            guard error == nil else {
                
                print(error!.localizedDescription)
                return
            }
            
            let value = snapshot?.value as? NSDictionary
            let profilePicURL = value?["profilePicUrl"] as? String ?? ""
            self.userName = value?["userName"] as? String ?? ""
            print("Profile URL -->> " + profilePicURL)
            if let url = URL(string: profilePicURL) {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard let imageData = data else { return }
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)!
                        self.userProfileImage = image
                        self.getItemsList(userID: userID)
                    }
                }.resume()
            }
            else{
                self.getItemsList(userID: userID)
            }
        })
    }
}

//MARK:- Collectionview delegates
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return feedList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCollectionCell", for: indexPath) as! FeedCollectionCell
        
        let currentFeed = feedList[indexPath.row]
        
        cell.feedImageView.kf.indicatorType = .activity
        let imageUrl = URL(string: currentFeed.feedImage)
        cell.feedImageView.kf.setImage(with: imageUrl)
        cell.shareButton.tag = indexPath.row
        cell.downloadBtn.tag = indexPath.row
        cell.feedTextLabel.text = currentFeed.feedText
        cell.shareButton.addTarget(self, action: #selector(shareBtnAct(_:)), for: .touchUpInside)
        cell.downloadBtn.addTarget(self, action: #selector(downloadBtnAct(_:)), for: .touchUpInside)
        //        cell.userNameLabel.text = "@\(currentFeed.userName)"
        cell.userNameLabel.text = self.userName
        cell.userProfileImage.image = self.userProfileImage
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
        
        let feedDate = dateFormatter.date(from: currentFeed.feedDate)
        let currentDate = dateFormatter.date(from: Date.getCurrentDate())
        
        let diff = Int(currentDate!.timeIntervalSince1970 - feedDate!.timeIntervalSince1970)
        let hours = diff / 3600
        let minutes = (diff - hours * 3600) / 60
        let days = hours/24
        if days < 7
        {
            if days != 0
            {
                if days == 1
                {
                    cell.dateTimeLbl.text = "Posted \(days) Day ago."
                }
                else
                {
                    cell.dateTimeLbl.text = "Posted \(days) Days ago."
                }
            }
            else if hours != 0
            {
                if hours == 1
                {
                    cell.dateTimeLbl.text = "Posted \(hours) Hour ago."
                }
                else
                {
                    cell.dateTimeLbl.text = "Posted \(hours) Hours ago."
                }
            }
            else if minutes != 0
            {
                cell.dateTimeLbl.text = "Posted \(minutes) minutes ago."
            }
            else
            {
                cell.dateTimeLbl.text = "Posted few movements ago."
            }
        }
        else
        {
            cell.dateTimeLbl.text = currentFeed.feedDate
        }
        
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
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var feedTextLabel: UILabel!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
}

//MARK:- FeedModel
struct FeedModel
{
    var userName = String()
    var feedText = String()
    var feedDate = String()
    var feedImage = String()
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
