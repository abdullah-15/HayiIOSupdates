//
//  FinalStepVC.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 18/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit

class FinalStepVC: UIViewController {

    @IBOutlet weak var Message: UILabel!
    var isVerified: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Completed"
        
        if isVerified {
            
            self.Message.text = "Your Account is verified. Login now to enjoy your community"
        }
        self.tabBarController?.tabBar.isHidden = true

        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        
        // Do any additional setup after loading the view.
    }
  
  
  override func viewWillAppear(_ animated: Bool) {
  self.navigationItem.setHidesBackButton(true, animated:true);
    self.tabBarController?.tabBar.isHidden = true

  }

  @IBAction func GoBack(_ sender: Any) {
    
    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    if let vc = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as?   SignInViewController
        
    {
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
  }
  
    @IBAction func backBtn(_ sender: Any) {
         let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         if let vc = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as?   SignInViewController
             
         {
             self.navigationController?.pushViewController(vc, animated: true)
         }
    }
    
    @IBAction func completeButton(_ sender: Any) {
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as?   SignInViewController
            
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
