//
//  DashBoardTabBarController.swift
//  Hayi
//
//  Created by Muhammad zain ul Abideen on 09/08/2019.
//  Copyright © 2019 Hayi. All rights reserved.
//

import UIKit

class DashBoardTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
      if(UIApplication.shared.isIgnoringInteractionEvents){
        UIApplication.shared.endIgnoringInteractionEvents()
      }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool)
       {
           super.viewWillDisappear(animated)
           self.navigationController?.isNavigationBarHidden = false
       }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
