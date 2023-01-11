//
//  SideNavigationVC.swift
//
//  Created by SS on 08/04/21.
//

import UIKit

class SideNavigationVC: UIViewController {
    
    @IBOutlet weak var navigationItemsTableView: UITableView!
    
    //MARK:- viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItemsTableView.delegate = self
        navigationItemsTableView.dataSource = self
    }
    
    //MARK:- viewWillAppear()
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        
    }
}

//MARK:- TableView Delegates
extension SideNavigationVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NavigationItemTableCell", for: indexPath) as! NavigationItemTableCell
        
//        cell.itemTitleLabel.text = navigationItemsList[indexPath.row]
//        cell.itemImageView.image = UIImage(named: navigationItemIconsList[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
}

//MARK:- NavigationItemTableCell
class NavigationItemTableCell: UITableViewCell
{
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
}
