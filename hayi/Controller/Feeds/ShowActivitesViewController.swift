//
//  ShowActivitesViewController.swift
//  hayi-ios2
//
//  Created by Mohsin on 03/10/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import SwiftyJSON



class ShowActivitesViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
   

    @IBOutlet weak var showCurrent: UILabel!
    var obj : AllCategories?
    var categories  = [AllCategories]()
    var isCategoriesLoaded = false
    @IBOutlet weak var showTbl: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         showTbl.delegate = self
         showTbl.dataSource = self
        // Do any additional setup after loading the view.
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        

        
        navigationItem.title = "Feed Types"
        
        self.showCurrent.text = AppManager.CategoryName
        
       
    }
    
    
    private func getAllCategories() {
       // HUD.show(.rotatingImage(UIImage(named: "progress")))
        
        let url = URL(string:"\(HelperFuntions.getAllcategories)")
                  // print("url is \(url)" )
        let MyHeader = ["content-type": "application/json"]
        
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding(options: []), headers: MyHeader).responseJSON{(responseJSON) in
            DispatchQueue.main.async {
                
                HUD.hide()
                switch responseJSON.result{
                    
                case .success(let data):
                    var statusCode:Int = 0
                    if responseJSON.result.value != nil{
                        
                        statusCode = (responseJSON.response?.statusCode)!
                        print("...HTTP code: \(statusCode)")
                    }
                    
                
                    if let res = responseJSON.result.value as? NSDictionary
                    {
                        
                        let dict = res
                        
                        
                        let json = JSON(dict.object(forKey: "postCategoryLookups") as Any).array
                        for a in json!
                        {
                            self.obj = AllCategories(json:a)
                            self.categories.append(self.obj!)
                            
                            
                        }
                        AppManager.categories = self.categories
                        let allActivity:AllCategories =  AllCategories(categoryId: 0, name: "All Activities")
                        self.categories.insert(allActivity, at: 0)
                    
                        
                        AppManager.isCategoriesLoaded = true
                        self.showTbl.reloadData()
                        
                        }
                    
                    let recievedCode = data as! NSDictionary
                    
                    let req = recievedCode.value(forKey: "requestResponse") as! NSDictionary
                    let result = req.value(forKey: "result") as! Bool
                    let status = req.value(forKey: "status") as! Int
                    
                    
                    print("Successfuly fetch relataed data \(data)")
                    DispatchQueue.main.async {
                        if statusCode == 200 && status == 1 && result == true{
                            
                           
                            
                        }else if status == 200 && status == 2 && result == false {
                            
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
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.categories.count

    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellA = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShowAllTableViewCell
        cellA.showLbl.text = self.categories[indexPath.row].name
        return cellA
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = self.categories[indexPath.row].postCategoriesId
        let name = self.categories[indexPath.row].name
        self.showCurrent.text = name!
        AppManager.categoryID = id!
        AppManager.CategoryName = name!
        AppManager.shouldLoadPostsAgain = true
        self.navigationController?.popViewController(animated: true)
        
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AppManager.isCategoriesLoaded == false {
            self.getAllCategories()
        }
        else {
            self.categories = AppManager.categories
            let allActivity:AllCategories =  AllCategories(categoryId: 0, name: "All Activities")
            self.categories.insert(allActivity, at: 0)
        }
        
    }
    
}
