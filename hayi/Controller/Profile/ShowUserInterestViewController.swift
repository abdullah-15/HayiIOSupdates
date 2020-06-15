//
//  ShowUserInterestViewController.swift
//  hayi-ios2
//
//  Created by Mohsin on 17/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD
import SDWebImage

class ShowUserInterestViewController: UIViewController {
    
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var userTable: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var subcommonID: Int?
    var searchs : String = ""
    
    var searching = false
    var filderarray  = [showUser]()
    var userArray : NSArray? = NSArray()
    var showUserdic  = [showUser]()
    var obj : showUser?
    var dataWithoutSearch = [showUser]()
    var pageNumber : Int = 1
    var PageLimit : Int = 30
    var request: DataRequest?
    var hasNext : Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        searchbar()
        
        userTable.delegate = self
        userTable.dataSource = self
       // addshadow(view : searchBarView)

        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        let yourBackImage = UIImage(named: "Back")
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
        self.title = AppManager.neighbourHoodName
        self.tabBarController?.tabBar.isHidden = true

        // Do any additional setup after loading the view.
        getSearchUser(search: searchs, pageNo: pageNumber, limit: PageLimit)
    }
    func addshadow(view : UIView)
    {
        
        view.setNeedsUpdateConstraints()
        view.layoutIfNeeded()
        view.updateConstraints()
        view.layer.cornerRadius = view.frame.size.height/2
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true

    }

    func searchbar()
    {
        //Searchbar Customization
        

        searchController.searchBar.isTranslucent = true
        searchController.searchBar.placeholder = "Find people by name or interest"

        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.tintColor = UIColor(red:0.40, green:0.27, blue:0.15, alpha:1.0)
        searchController.searchBar.backgroundColor = UIColor(red:0.40, green:0.27, blue:0.15, alpha:1.0)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        userTable.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.becomeFirstResponder()
        //searchController.searchBar.frame = self.searchBarView.frame
        
    }
    
    
    private func getSearchUser(search : String , pageNo : Int , limit : Int)
    {
        
        self.searching = true
        let neighbourHoodId = UserDefaultsManager.instance.getNeighbourHoodId()!
        
        let userId =  UserDefaultsManager.instance.CurrentUserId()!
        print("neighbourhood value \(neighbourHoodId)")
        
        let url = URL(string:"\(HelperFuntions.getAllUser)")
        let postString = ["neighbourhoodid": neighbourHoodId ,
                          "subComunityId" : subcommonID!,
                          "search" : search,
                          "page" : pageNo,
                          "length": limit,
                          "userId": userId
            ]  as [String : Any]
        
        print("post == \(postString)")
        let MyHeader = ["content-type": "application/json"]
        self.request = nil
        request = Alamofire.request(url!, method: .post, parameters: postString, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
            DispatchQueue.main.async {
                
                self.searching = false
                
                switch responseJSON.result{
                    
                case .success(let data):
                    // let decoder = JSONDecoder()
                    var statusCode:Int = 0
                    if responseJSON.result.value != nil{
                        
                        statusCode = (responseJSON.response?.statusCode)!
                        print("...HTTP code: \(statusCode)")
                    }
                    
                    
                    print(data)
                    HUD.hide()
                  

                    let recievedCode = data as! NSDictionary
                    self.hasNext = recievedCode.value(forKey: "hasNext") as? Bool

                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let result = req.value(forKey: "result") as! Bool
                    let status = req.value(forKey: "status") as! Int
                    //AppManager.invoicedata = self.address
                    
                    self.showUserdic = []
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == true{
                            
                            
                            if let res = responseJSON.result.value as? NSDictionary
                            {
                                
                                let dict = res
                                //var status = ""
                                // var eMsg = ""
                                
                                
                                let json = JSON(dict.object(forKey: "users") as Any).array
                                //let currentUserId = UserDefaultsManager.instance.CurrentUserId()
                                for a in json!
                                {
                                    self.obj = showUser(json:a)
                                   // if self.obj?.usersId != currentUserId {
                                        self.showUserdic.append(self.obj!)
                                    //}
                                }
                                
                                self.filderarray = self.showUserdic
                                
                                if search == "" && self.dataWithoutSearch.count == 0 {
                                    self.dataWithoutSearch = self.showUserdic
                                }
                                
                                self.userTable.reloadData()
                                print("Here :\(self.showUserdic)")
                                
                            }
                            
                        }else if statusCode == 200 && status == 2 && result == false {
                            let message = req.value(forKey: "msg") as! String
                            self.DisplayMessage(userMessage: message , title: "Error")
                            
                        }
                        
                    }
                    if statusCode == 401{
                        
                    }
                case .failure(let error):
                    print(error)
                    HUD.hide()
                }
                
            }
            
        }
    }
    
    func DisplayMessage(userMessage:String , title: String) -> Void {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: userMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default){(
                ACTION:UIAlertAction!) in
                //self.emptyAllTextFields()
                
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func getURL(url:String?) -> URL
    {
        let imageurl = url!
        let escapedString = imageurl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return URL(string:escapedString)!
    }
    @objc func displaycellDetails(_ sender : UIButton) {
        print(sender.tag)
        let indexPath = IndexPath(item: sender.tag, section: 0)
         let userID = self.filderarray[indexPath.row].usersId
        let userName = self.filderarray[indexPath.row].fullName
        let profilePic =  self.filderarray[indexPath.row].profileImage
        if let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "UserInfoViewController") as? UserInfoViewController
        {
            
            
            vc.userID =  userID!
            vc.userName =  userName!
            vc.isloggedInUser = false
            vc.profileImage =  profilePic
            AppManager.globalCheck = 2

            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }

    
}

extension ShowUserInterestViewController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filderarray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellA = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShowInterestTableViewCell
        
        cellA.Name.text = self.filderarray[indexPath.row].fullName
        cellA.profileImage.sd_setImage(with: self.getURL(url: self.filderarray[indexPath.row].profileImage))
        cellA.profileBtn.tag = indexPath.row
        cellA.profileBtn.addTarget(self, action: #selector(ShowUserInterestViewController.displaycellDetails(_:)), for:.touchUpInside)
        
        return cellA
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let intTotalrow = tableView.numberOfRows(inSection:indexPath.section)//first get total rows in that section by current indexPath.
        //get last last row of tablview
        if indexPath.row == intTotalrow - 1{
            
            if hasNext == true {
                pageNumber = pageNumber + 1
                 self.getSearchUser(search: searchs, pageNo: pageNumber, limit: 30)
            }
        }
    }
    
}
extension ShowUserInterestViewController : UISearchResultsUpdating ,UISearchBarDelegate{
    
    func updateSearchResults(for searchController: UISearchController) {
        // If we haven't typed anything into the search bar then do not filter the results
    
        if searchController.searchBar.text! == ""
        {
            filderarray = dataWithoutSearch
            self.request?.cancel()
            self.searching = false
        }
        else {
            
            self.searchs = searchController.searchBar.text!
            
            if self.searching {
                
                self.request?.cancel()
                self.searching = false
            }
            self.getSearchUser(search: searchs, pageNo: pageNumber, limit: PageLimit)
            
        }
        
         userTable.reloadData()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //let text = searchBar.text!

    }
}
